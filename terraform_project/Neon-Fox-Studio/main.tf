# 1. Main S3 Bucket Resource
resource "aws_s3_bucket" "neo_rahul_bucket" {
  bucket = "neo-rahul-bucket"
}

# 2. Public Access Block (Relax Public Access)
resource "aws_s3_bucket_public_access_block" "neo" {
  bucket = aws_s3_bucket.neo_rahul_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 3. IAM Policy Document
data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.neo_rahul_bucket.arn}/*"
    ]
  }
}


resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.neo_rahul_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json

  depends_on = [aws_s3_bucket_public_access_block.neo]
}

resource "aws_s3_bucket_website_configuration" "neo_studio" {
  bucket = aws_s3_bucket.neo_rahul_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

# 6. S3 Object
resource "aws_s3_object" "index_file" {
  bucket       = aws_s3_bucket.neo_rahul_bucket.id
  key          = "index.html"
  content      = "<h1>Welcome to Neon Fox Studio</h1>"
  content_type = "text/html"
  
}