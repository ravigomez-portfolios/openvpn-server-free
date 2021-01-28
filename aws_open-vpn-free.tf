terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_vpc" "openvpn-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "openvpn-free"
  }
}

resource "aws_internet_gateway" "openvpn-ig" {
  vpc_id = aws_vpc.openvpn-vpc.id
  tags = {
    Name = "openvpn-free"
  }
}

resource "aws_route_table" "openvpn-rt" {
  vpc_id = aws_vpc.openvpn-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.openvpn-ig.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.openvpn-ig.id
  }
  tags = {
    Name = "openvpn-free"
  }
}

resource "aws_subnet" "openvpn-sn" {
  vpc_id     = aws_vpc.openvpn-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "openvpn-free"
  }
}

resource "aws_route_table_association" "openvpn-rta" {
  subnet_id      = aws_subnet.openvpn-sn.id
  route_table_id = aws_route_table.openvpn-rt.id
}

resource "aws_security_group" "openvpn-sg" {
  name        = "openvpn-free"
  description = "openvpn-free"
  vpc_id      = aws_vpc.openvpn-vpc.id

  ingress {
    description = "openvpn-free"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "openvpn"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "openvpn"
    from_port   = 945
    to_port     = 945
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "openvpn"
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "openvpn"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "openvpn-free"
  }
}

resource "aws_network_interface" "openvpn-ni" {
  subnet_id       = aws_subnet.openvpn-sn.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.openvpn-sg.id]
  tags = {
    Name = "openvpn-free"
  }
}

resource "aws_eip" "openvpn-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.openvpn-ni.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_security_group.openvpn-sg]
  tags = {
    Name = "openvpn-free"
  }
}

resource "aws_instance" "openvpn-free" {
  ami           = "ami-04bde880fb57a5227"
  instance_type = "t2.nano"
  key_name      = "openvpn-brazil"
  availability_zone = "sa-east-1a"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.openvpn-ni.id
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update && sudo apt-get upgrade -y
              EOF
  tags = {
    Name = "openvpn-free"
  }
}
