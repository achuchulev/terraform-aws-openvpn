resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_block}"

  tags {
    Name = "openvpn"
  }
}

resource "aws_subnet" "vpn_subnet" {
  vpc_id                  = "${aws_vpc.main.id}"
  map_public_ip_on_launch = true
  cidr_block              = "${var.subnet_cidr_block}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "Internet Gateway for openvpn"
  }
}

resource "aws_eip" "openvpn_eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_route" "internet_access_openvpn" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_key_pair" "openvpn" {
  key_name   = "openvpn-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "openvpn" {
  name        = "openvpn_sg"
  description = "Allow traffic needed by openvpn"
  vpc_id      = "${aws_vpc.main.id}"

  // Custom ICMP Rule - IPv4 Echo Reply
  ingress {
    from_port   = "0"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["${var.ssh_cidr}"]
  }

  // Custom ICMP Rule - IPv4 Echo Request
  ingress {
    from_port   = "8"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["${var.ssh_cidr}"]
  }

  // ssh
  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_cidr}"]
  }

  // http
  ingress {
    from_port   = "${var.http_port}"
    to_port     = "${var.http_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.http_cidr}"]
  }

  // https
  ingress {
    from_port   = "${var.https_port}"
    to_port     = "${var.https_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.https_cidr}"]
  }

  // open vpn tcp
  ingress {
    from_port   = "${var.tcp_port}"
    to_port     = "${var.tcp_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.tcp_cidr}"]
  }

  // open vpn udp
  ingress {
    from_port   = "${var.udp_port}"
    to_port     = "${var.udp_port}"
    protocol    = "udp"
    cidr_blocks = ["${var.udp_cidr}"]
  }

  // all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creates a DNS record with Cloudflare
resource "cloudflare_record" "vpn" {
  domain = "${var.cloudflare_zone}"
  name   = "${var.cloudflare_subdomain}"
  value  = "${aws_eip_association.vpn_eip_assoc.public_ip}"
  type   = "A"
  ttl    = "${var.subdomain_ttl}"
}

resource "aws_eip_association" "vpn_eip_assoc" {
  instance_id   = "${aws_instance.openvpn.id}"
  allocation_id = "${aws_eip.openvpn_eip.id}"
}

resource "aws_instance" "openvpn" {
  tags {
    Name = "openvpn"
  }

  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.openvpn.key_name}"
  subnet_id                   = "${aws_subnet.vpn_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.openvpn.id}"]
  associate_public_ip_address = true
  source_dest_check           = false

  # `admin_user` and `admin_pw` need to be passed in to the appliance through `user_data`, see docs -->
  # https://docs.openvpn.net/how-to-tutorialsguides/virtual-platforms/amazon-ec2-appliance-ami-quick-start-guide/
  user_data = <<USERDATA
public_hostname=${var.cloudflare_subdomain}.${var.cloudflare_zone}
admin_user=${var.admin_user}
admin_pw=${var.admin_password}
reroute_gw=1
reroute_dns=1
USERDATA
}

#Configur openvpn access server
resource "null_resource" "configure_openvpn_access_server" {
  triggers {
    subdomain_id = "${cloudflare_record.vpn.id}"
  }

  connection {
    type        = "ssh"
    host        = "${aws_eip_association.vpn_eip_assoc.public_ip}"
    user        = "${var.ssh_user}"
    port        = "${var.ssh_port}"
    private_key = "${file("~/.ssh/id_rsa")}"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo service openvpnas stop",
      "sleep 5",
      "sudo certbot certonly --standalone --non-interactive --agree-tos --email ${var.cloudflare_email} --domains ${var.cloudflare_subdomain}.${var.cloudflare_zone} --pre-hook 'service openvpnas stop' --post-hook 'service openvpnas start'",
      "sudo ln -s -f /etc/letsencrypt/live/${var.cloudflare_subdomain}.${var.cloudflare_zone}/fullchain.pem /usr/local/openvpn_as/etc/web-ssl/server.crt",
      "sudo ln -s -f /etc/letsencrypt/live/${var.cloudflare_subdomain}.${var.cloudflare_zone}/privkey.pem /usr/local/openvpn_as/etc/web-ssl/server.key",
      "sudo service openvpnas start",
      "sleep 15",
      "sudo /usr/local/openvpn_as/scripts/sacli --key vpn.server.routing.private_access --value route ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key vpn.client.routing.inter_client --value true ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key vpn.client.routing.reroute_dns --value false ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli --key vpn.client.routing.reroute_gw --value false ConfigPut",
    ]
  }
}
