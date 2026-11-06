resource "aws_s3_bucket" "student_bucket" {
  bucket = "rahul-tf-s3-6496"

  tags = {
    Name        = "rahul-tf-s3-6496"
    Environment = "Dev"
    Managedby   = "terraform"
    Owner       = "rahul"
  }
}

resource "aws_s3_bucket_versioning" "student_bucket_versioning" {
  bucket = aws_s3_bucket.student_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "student_bucket_public_access" {
  bucket = aws_s3_bucket.student_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
