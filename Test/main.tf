provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# SSH Key Pair
resource "aws_key_pair" "ansible_key" {
  key_name   = "2915"
  public_key = file("/home/rmavani/.ssh/2915.pub")
}

# EC2 Server 1
resource "aws_instance" "rahul_1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = aws_key_pair.ansible_key.key_name

  tags = {
    Name = "HelloWorld from Rahul1"
  }
}

# EC2 Server 2
resource "aws_instance" "rahul_2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = aws_key_pair.ansible_key.key_name

  tags = {
    Name = "HelloWorld from Rahul2"
  }
}

# Outputs
output "server1_public_ip" {
  value = aws_instance.rahul_1.public_ip
}

output "server1_public_dns" {
  value = aws_instance.rahul_1.public_dns
}

output "server2_public_ip" {
  value = aws_instance.rahul_2.public_ip
}

output "server2_public_dns" {
  value = aws_instance.rahul_2.public_dns
}