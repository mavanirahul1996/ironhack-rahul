terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Ubuntu 24.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "ansible_lab" {
  name        = "ansible-lab-sg"
  description = "Security group for Ansible lab"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Web Server
resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "YOUR_KEY_NAME"
  vpc_security_group_ids = [aws_security_group.ansible_lab.id]

  tags = {
    Name = "ansible-webserver"
  }
}

# Load Balancer Server
resource "aws_instance" "loadbalancer" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "YOUR_KEY_NAME"
  vpc_security_group_ids = [aws_security_group.ansible_lab.id]

  tags = {
    Name = "ansible-loadbalancer"
  }
}

# Outputs
output "webserver_public_ip" {
  value = aws_instance.webserver.public_ip
}

output "loadbalancer_public_ip" {
  value = aws_instance.loadbalancer.public_ip
}