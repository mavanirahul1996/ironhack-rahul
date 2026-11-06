variable "ami_id" {
  description = "AMI ID for the application server"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "s3_bucket_name" {
  description = "S3 bucket for payroll documents"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for payroll data"
  type        = string
}