# ==================================================
# PROVIDER
# ==================================================

provider "aws" {
  region = "us-east-1"
}

# ==================================================
# UBUNTU AMI - US
# ==================================================

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ==================================================
# SSH KEY PAIR
# ==================================================

resource "aws_key_pair" "lab" {
  key_name_prefix = "rahul_sep26-"
  public_key      = file(pathexpand("~/.ssh/rahul_sep26.pub"))
}

# ==================================================
# SECURITY GROUP
# ==================================================

resource "aws_security_group" "ssh" {
  name_prefix = "rahul_sep26-"

  ingress {
    from_port   = 22
    to_port     = 22
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

# ==================================================
# 2.1 - depends_on
# ==================================================

resource "aws_s3_bucket" "data_bucket" {
  bucket_prefix = "rahul-data-bucket-"
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  depends_on = [aws_s3_bucket.data_bucket]

  tags = {
    Name  = "Rahul-App-Server"
    Owner = "Rahul"
  }
}

# ==================================================
# 2.2 - count
# ==================================================

resource "aws_instance" "web" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name  = "Rahul-Web-${count.index + 1}"
    Owner = "Rahul"
  }
}

# ==================================================
# 2.3 - for_each
# ==================================================

variable "server_names" {
  type    = set(string)
  default = ["app1", "app2", "app3"]
}

resource "aws_instance" "servers" {
  for_each = var.server_names

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name  = "Rahul-${each.key}"
    Owner = "Rahul"
  }
}

# ==================================================
# 2.4 - lifecycle
# ==================================================

resource "aws_s3_bucket" "data" {
  bucket_prefix = "rahul-protected-bucket-"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name  = "Rahul-Protected-Bucket"
    Owner = "Rahul"
  }
}

# ==================================================
# 2.5 - PROVIDER META ARGUMENT
# ==================================================

# US provider
provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

# EU alias
# NOTE:
# eu-west-1 is restricted in your AWS account,
# so we use us-east-1 for this lab.
provider "aws" {
  alias  = "eu"
  region = "us-east-1"
}

# AMI using EU provider alias
data "aws_ami" "ubuntu_eu" {
  provider    = aws.eu
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# US Server
resource "aws_instance" "us_server" {
  provider      = aws.us
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name  = "Rahul-US-Server"
    Owner = "Rahul"
  }
}

# EU Server
resource "aws_instance" "eu_server" {
  provider      = aws.eu
  ami           = data.aws_ami.ubuntu_eu.id
  instance_type = "t2.micro"

  tags = {
    Name  = "Rahul-EU-Server"
    Owner = "Rahul"
  }
}

# ==================================================
# 2.6 - PROVISIONER + CONNECTION
# ==================================================

resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name               = aws_key_pair.lab.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name  = "Rahul-Nginx-App"
    Owner = "Rahul"
  }

  connection {
    type = "ssh"
    user = "ubuntu"

    private_key = file(pathexpand("~/.ssh/rahul_sep26"))

    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait > /dev/null || true",
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo systemctl start nginx"
    ]
  }
}

# ==================================================
# 2.7 - CONNECTION + remote-exec
# ==================================================

resource "aws_instance" "web_ssh" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name               = aws_key_pair.lab.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name  = "Rahul-Web-SSH"
    Owner = "Rahul"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"

      private_key = file(pathexpand("~/.ssh/rahul_sep26"))

      host = self.public_ip
    }

    inline = [
      "echo Hello, Rahul and Terraform!"
    ]
  }
}