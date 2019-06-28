variable "aws_region" {}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "openvpn_remote_client_user" {
  default = "client01"
}

variable "openvpn_remote_client_passwd" {
  default = "changemenow"
}

variable "subsidiary_network" {
  default = "172.31.0.0/16"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  default = "10.0.0.0/16"
}

variable "ssh_user" {
  default = "openvpnas"
}

variable "ssh_port" {
  default = 22
}

variable "ssh_cidr" {
  default = "0.0.0.0/0"
}

variable "https_port" {
  default = 443
}

variable "https_cidr" {
  default = "0.0.0.0/0"
}

variable "http_port" {
  default = 80
}

variable "http_cidr" {
  default = "0.0.0.0/0"
}

variable "tcp_port" {
  default = 943
}

variable "tcp_cidr" {
  default = "0.0.0.0/0"
}

variable "udp_port" {
  default = 1194
}

variable "udp_cidr" {
  default = "0.0.0.0/0"
}

#variable "route53_zone_name" {}
#variable "subdomain_name" {}

variable "subdomain_ttl" {
  default = "3600"
}

variable "ami" {
  default = "ami-07a8d85046c8ecc99" // ubuntu xenial openvpn ami in eu-west-1
}

variable "instance_type" {
  default = "t2.medium"
}

variable "admin_user" {
  default = "openvpn"
}

variable "admin_password" {
  default = "openvpn"
}

#variable "certificate_email" {}

variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_zone" {}
variable "cloudflare_subdomain" {}
