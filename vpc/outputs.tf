output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}
output "web_subnet_ids" {
  description = "The IDs of the web subnets"
  value       = [for web in aws_subnet.web : web.id]
}
output "app_subnet_ids" {
  description = "The IDs of the app subnets"
  value       = [for app in aws_subnet.app : app.id]
}
output "db_subnet_ids" {
  description = "The IDs of the db subnets"
  value       = [for db in aws_subnet.db : db.id]
}
output "db_subnet_group_name" {
  description = "value of the db subnet group name"
  value       = aws_db_subnet_group.default.name
}