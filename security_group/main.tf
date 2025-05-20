locals {
  name = "${var.environment}-${var.project_name}-${var.sg_name}"
}

resource "aws_security_group" "example" {
  name        = local.name 
  description = var.sg_description
  vpc_id      = var.vpc_id

   dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
    egress  {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  tags = merge(
    {
      Name = local.name
    },
    var.common_tags
  )
}