variable "ami_image_name" {
  description = "AMI image for the instance"
  type        = string
  default     = "ami-07d9b9ddc6cd8dd30"  # Ensure this AMI ID is valid in your region
}
 
variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}