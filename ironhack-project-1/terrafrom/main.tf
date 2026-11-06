
terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "voting-tfstate-rahul-20261012"
    key          = "voting-project/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 5.5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --------------------------------------------------
# Variables
# --------------------------------------------------

variable "ssh_allowed_cidr" {
  description = "Your public IP address in CIDR format"
  type        = string
  default     = "93.235.31.239/32"
}

variable "key_name" {
  description = "Existing EC2 key pair in us-east-1"
  type        = string
  default     = "rahul_sep26_rsa"
}

# --------------------------------------------------
# Amazon Linux AMI
# --------------------------------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# --------------------------------------------------
# VPC
# --------------------------------------------------

resource "aws_vpc" "voting_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "voting-vpc"
  }
}

# --------------------------------------------------
# Public Subnet - Existing resource
# --------------------------------------------------

resource "aws_subnet" "voting_subnet_public_rahul" {
  vpc_id                  = aws_vpc.voting_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "voting-public-subnet_rahul"
  }
}

# --------------------------------------------------
# OLD PRIVATE SUBNET - Keep it to preserve GuardDuty
# --------------------------------------------------

resource "aws_subnet" "voting_subnet_private" {
  vpc_id                  = aws_vpc.voting_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "voting-private-subnet"
  }
}

# --------------------------------------------------
# NEW PRIVATE SUBNET - Use this for private instances
# --------------------------------------------------

resource "aws_subnet" "voting_subnet_private_rahul" {
  vpc_id                  = aws_vpc.voting_vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "voting-private-subnet_rahul"
  }
}

# --------------------------------------------------
# Internet Gateway
# --------------------------------------------------

resource "aws_internet_gateway" "voting_igw_rahul" {
  vpc_id = aws_vpc.voting_vpc.id

  tags = {
    Name = "voting-igw-rahul"
  }
}

# --------------------------------------------------
# Public Route Table
# --------------------------------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.voting_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.voting_igw_rahul.id
  }

  tags = {
    Name = "voting-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.voting_subnet_public_rahul.id
  route_table_id = aws_route_table.public_rt.id
}

# --------------------------------------------------
# Private Route Table
# --------------------------------------------------

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.voting_vpc.id

  tags = {
    Name = "voting-private-rt"
  }
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.voting_subnet_private_rahul.id
  route_table_id = aws_route_table.private_rt.id
}

# --------------------------------------------------
# Security Group - Instance A (Vote / Result App)
# Keep original description to avoid unnecessary replacement
# --------------------------------------------------

resource "aws_security_group" "app_sg" {
  name        = "voting-app-sg"
  description = "Access for Vote and Result apps and Bastion"
  vpc_id      = aws_vpc.voting_vpc.id

  ingress {
    description = "SSH from allowed IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Vote app"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Result app"
    from_port   = 8081
    to_port     = 8081
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
    Name = "voting-app-sg"
  }
}

# --------------------------------------------------
# Security Group - Instance B (Redis Worker)
# --------------------------------------------------

resource "aws_security_group" "redis_worker_sg" {
  name        = "redis-worker-sg"
  description = "Access for Redis worker"
  vpc_id      = aws_vpc.voting_vpc.id

  ingress {
    description     = "SSH from app security group"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  ingress {
    description     = "Redis traffic from app security group"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-worker-sg"
  }
}

# --------------------------------------------------
# Security Group - Instance C (PostgreSQL)
# --------------------------------------------------

resource "aws_security_group" "postgresql_sg" {
  name        = "postgresql-sg"
  description = "Access for PostgreSQL database"
  vpc_id      = aws_vpc.voting_vpc.id

  ingress {
    description     = "SSH from app security group"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  ingress {
    description     = "PostgreSQL from frontend app"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  ingress {
    description     = "PostgreSQL from Redis worker"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.redis_worker_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "postgresql-sg"
  }
}

# --------------------------------------------------
# Instance A - Public App
# --------------------------------------------------

resource "aws_instance" "instance_a" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.voting_subnet_public_rahul.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "voting-instance-a"
  }
}

# --------------------------------------------------
# Instance B - Private Redis Worker
# Uses the _rahul private subnet
# --------------------------------------------------

resource "aws_instance" "instance_b" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.voting_subnet_private_rahul.id
  vpc_security_group_ids = [aws_security_group.redis_worker_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "voting-instance-b"
  }
}

# --------------------------------------------------
# Instance C - Private PostgreSQL
# Uses the _rahul private subnet
# --------------------------------------------------

resource "aws_instance" "instance_c" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.voting_subnet_private_rahul.id
  vpc_security_group_ids = [aws_security_group.postgresql_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "voting-instance-c"
  }
}

# --------------------------------------------------
# Outputs
# --------------------------------------------------

output "vpc_id" {
  value = aws_vpc.voting_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.voting_subnet_public_rahul.id
}

output "private_subnet_id" {
  value = aws_subnet.voting_subnet_private_rahul.id
}

output "public_ip" {
  value = aws_instance.instance_a.public_ip
}

output "instance_b_private_ip" {
  value = aws_instance.instance_b.private_ip
}

output "instance_c_private_ip" {
  value = aws_instance.instance_c.private_ip
}
