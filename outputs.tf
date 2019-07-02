output "vpn_server_public_ip" {
  value = "${aws_eip_association.vpn_eip_assoc.public_ip}"
}
