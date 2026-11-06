provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "frankfurt"
  region = "eu-central-1"
}

module "payroll" {
  source              = "./modules/payroll"
  ami_id              = "ami-07d9b9ddc6cd8dd30"
  instance_type       = "t2.micro"
  s3_bucket_name      = "r-payroll-docs-us-east-1"
  dynamodb_table_name = "r-PayrollDB"
}

module "payroll_frankfurt" {
  source = "./modules/payroll"

  providers = {
    aws = aws.frankfurt
  }

  ami_id              = "YOUR_VALID_FRANKFURT_AMI"
  instance_type       = "t2.micro"
  s3_bucket_name      = "payroll-docs-frankfurt-unique-r-2026"
  dynamodb_table_name = "PayrollDB-Frankfurt-r"
}