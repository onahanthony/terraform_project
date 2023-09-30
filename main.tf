terraform {

  cloud {
    organization = "cloudprof"

    workspaces {
      name = "terraform_project"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.15.0"
    }
  }
}
provider "aws" {
}
# security group 
variable "main" {
  type    = string
  default = "vpc-0fc04ba251345b5d1"

}
resource "aws_security_group" "http" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.main

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
  ingress {
    description      = "allow ssh "
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
  ingress {
    description      = "allow http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  tags = {
    Name = "allow_tls"
  }
}

variable "ami" {
  type    = string
  default = "ami-051f7e7f6c2f40dc1"
}

locals {
  instance_type = "t2.micro"
  private_key_path = "~/my-key.pem"
}

resource "aws_instance" "test" {
  ami                    = var.ami
  instance_type          = local.instance_type
  key_name               = "my-key"
  vpc_security_group_ids = [aws_security_group.http.id]

  tags = {
    Name = "HelloWorld"
  }
}

output "instance_ip_addr" {
  value       = aws_instance.test.public_ip
  description = "The public IP address of the main server instance."
}
