terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "sa-east-1"
}

resource "aws_instance" "openvpn-example" {
  ami           = "ami-04bde880fb57a5227"
  instance_type = "t2.micro"
}
