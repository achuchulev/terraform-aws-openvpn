variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {
  default = "us-east-1"
}

variable "openvpn_remote_client_user" {
  default = "client01"
}

variable "openvpn_remote_client_passwd" {
  default = "changemenow"
}

variable "subsidiary_network" {
  default = "10.10.0.0/16"
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

variable "subdomain_ttl" {
  default = "3600"
}

variable "ami" {
  default = "ami-005a7a7754837820c" // ubuntu xenial openvpn ami in us-east-1
}

variable "instance_type" {
  default = "t2.micro"
}

variable "admin_user" {
  default = "openvpn"
}

variable "admin_password" {
  default = "openvpn"
}

variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_zone" {}
variable "cloudflare_subdomain" {}
