# Dynamically fetch the latest Amazon Linux 2023 AMI for the target region
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "payroll_server" {
  # Use the dynamic SSM parameter instead of a hardcoded AMI ID string
  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type
 
  tags = {
    Name = "Payroll-Server"
  }
}
 
resource "aws_s3_bucket" "payroll_docs" {
  bucket = var.s3_bucket_name
}
 
resource "aws_dynamodb_table" "payroll_db" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "EmployeeID"
 
  attribute {
    name = "EmployeeID"
    type = "S"
  }
}