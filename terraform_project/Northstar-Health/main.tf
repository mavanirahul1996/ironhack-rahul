provider "aws" {
  region = "us-east-1"
}

# -------------------------------------------------
# Student Name
# -------------------------------------------------

variable "student_name" {
  description = "Student name used for resource naming and tagging"
  type        = string
  default     = "rahul"
}

# -------------------------------------------------
# VPC
# -------------------------------------------------

resource "aws_vpc" "northstart_health_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.student_name}-northstart-health-vpc"
    StudentName = var.student_name
  }
}

# -------------------------------------------------
# Public Subnet 1 - us-east-1a
# -------------------------------------------------

resource "aws_subnet" "northstart_health_public_1" {
  vpc_id                  = aws_vpc.northstart_health_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.student_name}-public-1"
    StudentName = var.student_name
  }
}

# -------------------------------------------------
# Public Subnet 2 - us-east-1b
# -------------------------------------------------

resource "aws_subnet" "northstart_health_public_2" {
  vpc_id                  = aws_vpc.northstart_health_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.student_name}-public-2"
    StudentName = var.student_name
  }
}

# -------------------------------------------------
# Private Subnet 1 - us-east-1a
# -------------------------------------------------

resource "aws_subnet" "northstart_health_private_1" {
  vpc_id            = aws_vpc.northstart_health_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "${var.student_name}-private-1"
    StudentName = var.student_name
  }
}

# -------------------------------------------------
# Private Subnet 2 - us-east-1b
# -------------------------------------------------

resource "aws_subnet" "northstart_health_private_2" {
  vpc_id            = aws_vpc.northstart_health_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name        = "${var.student_name}-private-2"
    StudentName = var.student_name
  }
}

# -------------------------------------------------
# Internet Gateway
# -------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.northstart_health_vpc.id

  tags = {
    Name        = "${var.student_name}-igw"
    StudentName = var.student_name
  }
}

# -------------------------------------------------
# Elastic IP for NAT Gateway
# -------------------------------------------------

resource "aws_eip" "northstart_health_nat_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.student_name}-nat-eip"
    StudentName = var.student_name
  }
}

# -------------------------------------------------
# NAT Gateway
# NAT Gateway MUST be in a PUBLIC subnet
# -------------------------------------------------

resource "aws_nat_gateway" "northstart_health_nat" {
  allocation_id = aws_eip.northstart_health_nat_eip.id
  subnet_id     = aws_subnet.northstart_health_public_1.id

  tags = {
    Name        = "${var.student_name}-nat-gateway"
    StudentName = var.student_name
  }

  depends_on = [aws_internet_gateway.igw]
}

# -------------------------------------------------
# Public Route Table
# Internet traffic -> Internet Gateway
# -------------------------------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.northstart_health_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.student_name}-public-route-table"
    StudentName = var.student_name
  }
}

# -------------------------------------------------
# Public Subnet 1 -> Public Route Table
# -------------------------------------------------

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.northstart_health_public_1.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------------------------------
# Public Subnet 2 -> Public Route Table
# -------------------------------------------------

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.northstart_health_public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------------------------------
# Private Route Table
# Private traffic -> NAT Gateway
# -------------------------------------------------

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.northstart_health_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.northstart_health_nat.id
  }

  tags = {
    Name        = "${var.student_name}-private-route-table"
    StudentName = var.student_name
  }
}

# -------------------------------------------------
# Private Subnet 1 -> Private Route Table
# -------------------------------------------------

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.northstart_health_private_1.id
  route_table_id = aws_route_table.private_rt.id
}

# -------------------------------------------------
# Private Subnet 2 -> Private Route Table
# -------------------------------------------------

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.northstart_health_private_2.id
  route_table_id = aws_route_table.private_rt.id
}

# -------------------------------------------------
# Outputs
# -------------------------------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.northstart_health_vpc.id
}

output "public_subnet_1_id" {
  description = "Public subnet 1 ID"
  value       = aws_subnet.northstart_health_public_1.id
}

output "public_subnet_2_id" {
  description = "Public subnet 2 ID"
  value       = aws_subnet.northstart_health_public_2.id
}

output "private_subnet_1_id" {
  description = "Private subnet 1 ID"
  value       = aws_subnet.northstart_health_private_1.id
}

output "private_subnet_2_id" {
  description = "Private subnet 2 ID"
  value       = aws_subnet.northstart_health_private_2.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.northstart_health_nat.id
}