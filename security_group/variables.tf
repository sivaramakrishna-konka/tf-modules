variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}
variable "sg_description" {
  description = "Description of the security group"
  type        = string
}
variable "sg_name" {
  description = "Name of the security group"
  type        = string
}
variable "environment" {
  description = "The environment for the security group"
  type        = string
}
variable "project_name" {
  description = "The project name for the security group"
  type        = string
}
variable "common_tags" {
  description = "Common tags to be applied to the security group"
  type        = map(string)
  default     = {}
}
variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}