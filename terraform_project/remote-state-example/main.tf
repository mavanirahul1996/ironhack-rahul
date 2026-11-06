resource "aws_instance" "web_server" {
  ami           = var.ami_image_name
  instance_type = var.instance_type
 
  tags = {
    Name = "Terraform-Managed-Instance"
  }
}