terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.67.0"
    }
  }

  backend "s3" {
    bucket       = "surf-tfstate-rahul"
    key          = "ericeira/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  default = "us-east-1"
}

variable "my_ip" {
  description = "Your public IP in CIDR form"
  type        = string
}

resource "aws_vpc" "surf_rahul" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "surf-rahul"
  }
}

resource "aws_subnet" "subnet_surf_rahul" {
  cidr_block              = "10.1.1.0/24"
  vpc_id                  = aws_vpc.surf_rahul.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "surf-public-a-rahul"
  }
}

resource "aws_internet_gateway" "igw_rahul" {
  vpc_id = aws_vpc.surf_rahul.id

  tags = {
    Name = "surf-igw-rahul"
  }
}

resource "aws_route_table" "public_rahul" {
  vpc_id = aws_vpc.surf_rahul.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_rahul.id
  }

  tags = {
    Name = "surf-public-route-rahul"
  }
}

resource "aws_route_table_association" "public_rahul" {
  subnet_id      = aws_subnet.subnet_surf_rahul.id
  route_table_id = aws_route_table.public_rahul.id
}

resource "aws_security_group" "surf_web_rahul" {
  name   = "surf-web-sg-rahul"
  vpc_id = aws_vpc.surf_rahul.id

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP from anywhere"
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

  tags = {
    Name = "surf-web-sg-rahul"
  }
}

resource "aws_key_pair" "surf_key_rahul" {
  key_name   = "surf-key-rahul"
  public_key = file("/home/rmavani/.ssh/surf-camp-rahul.pub")
}

data "aws_ami" "rahul123" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "web_rahul" {
  ami           = data.aws_ami.rahul123.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.subnet_surf_rahul.id

  vpc_security_group_ids = [
    aws_security_group.surf_web_rahul.id
  ]

  key_name = aws_key_pair.surf_key_rahul.key_name

  tags = {
    Name = "surf-web-rahul"
  }
}

output "web_public_ip" {
  value = aws_instance.web_rahul.public_ip
}