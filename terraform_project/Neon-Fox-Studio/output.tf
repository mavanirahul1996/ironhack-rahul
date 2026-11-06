output "website_endpoint" {
  description = "S3 bucket website endpoint"
  value       = aws_s3_bucket_website_configuration.neo_studio.website_endpoint
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.neo_rahul_bucket.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.neo_rahul_bucket.arn
}