output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.example.public_ip
}
output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.example.private_ip
}



