output "vpn_server_public_ip" {
  value = "${aws_eip_association.vpn_eip_assoc.public_ip}"
}

output "vpn_access_server_main_route_table_id" {
  value = "${aws_vpc.main.main_route_table_id}"
}

output "vpn_access_server_instance_id" {
  value = "${aws_instance.openvpn.id}"
}
