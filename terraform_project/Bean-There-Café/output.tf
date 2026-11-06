output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "web_server_url" {
  description = "Clickable URL to access the web server"
  value       = "http://${aws_instance.web.public_ip}"
}