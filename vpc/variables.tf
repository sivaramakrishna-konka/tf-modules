variable "environment" {
  description = "Environment name"
  type        = string
}
variable "project_name" {
  description = "project name"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
variable "web_subnet_cidr_block" {
  description = "CIDR block for the web subnet"
  type        = list(string)
}
variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = []
}
variable "app_subnet_cidr_block" {
  description = "CIDR block for the web subnet"
  type        = list(string)
}
variable "db_subnet_cidr_block" {
  description = "CIDR block for the web subnet"
  type        = list(string)
}
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}
variable "enable_flow_logs" {
  description = "Enable flow logs"
  type        = bool
}