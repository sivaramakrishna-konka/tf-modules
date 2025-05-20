locals {
  common_name = "${var.environment}-${var.project_name}"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${local.common_name}-vpc"
    },
    var.common_tags
  )
}
resource "aws_subnet" "web" {
  count = length(var.web_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.web_subnet_cidr_block[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    {
    Name = "${local.common_name}-web-subnet-${split("-",var.azs[count.index])[2]}"
    },
    var.common_tags
   )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${local.common_name}-igw"
    },
    var.common_tags
  )
}

resource "aws_subnet" "app" {
  count = length(var.app_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.app_subnet_cidr_block[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(
    {
    Name = "${local.common_name}-app-subnet-${split("-",var.azs[count.index])[2]}"
    },
    var.common_tags
   )
}

resource "aws_subnet" "db" {
  count = length(var.db_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.db_subnet_cidr_block[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(
    {
    Name = "${local.common_name}-db-subnet-${split("-",var.azs[count.index])[2]}"
    },
    var.common_tags
   )
}

resource "aws_db_subnet_group" "default" {
  name       = local.common_name
  subnet_ids = [for subnet in aws_subnet.db : subnet.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_route_table" "web" {
  vpc_id = aws_vpc.main.id

  
  tags = merge(
    {
      Name = "${local.common_name}-web-rt"
    },
    var.common_tags
  )
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  
  tags = merge(
    {
      Name = "${local.common_name}-app-rt"
    },
    var.common_tags
  )
}
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  
  tags = merge(
    {
      Name = "${local.common_name}-db-rt"
    },
    var.common_tags
  )
}

resource "aws_route_table_association" "web" {
  count = length(aws_subnet.web)
  subnet_id      = aws_subnet.web[count.index].id
  route_table_id = aws_route_table.web.id
}

resource "aws_route_table_association" "app" {
  count = length(aws_subnet.app)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "db" {
  count = length(aws_subnet.db)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}

resource "aws_route" "web_public_route" {
  route_table_id            = aws_route_table.web.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  domain   = "vpc"
  tags = merge(
    {
      Name = "${local.common_name}-eip"
    },
    var.common_tags
  )
}

resource "aws_nat_gateway" "example" {
  count = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.web[0].id

  tags = merge(
    {
      Name = "${local.common_name}-nat"
    },
    var.common_tags
  )
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_route" "app_nat_route" {
  count = var.enable_nat_gateway ? 1 : 0
  route_table_id            = aws_route_table.app.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.example[count.index].id
}
resource "aws_route" "db_nat_route" {
  count = var.enable_nat_gateway ? 1 : 0
  route_table_id            = aws_route_table.db.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.example[count.index].id
}
### VPC flow logs
resource "aws_flow_log" "example" {
  count = var.enable_flow_logs ? 1 : 0
  iam_role_arn    = aws_iam_role.example[count.index].arn
  log_destination = aws_cloudwatch_log_group.example[count.index].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
  tags = merge(
    {
      Name = "${local.common_name}-vpc-flow-logs"
    },
    var.common_tags
  )
}

resource "aws_cloudwatch_log_group" "example" {
  count = var.enable_flow_logs ? 1 : 0
  name = "${local.common_name}-vpc-flow-logs"
  tags = merge(
    {
      Name = "${local.common_name}-vpc-flow-logs"
    },
    var.common_tags
  )
}

data "aws_iam_policy_document" "assume_role" {
  count = var.enable_flow_logs ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  count = var.enable_flow_logs ? 1 : 0
  name               = "${local.common_name}-vpc-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.assume_role[count.index].json
}

data "aws_iam_policy_document" "example" {
  count = var.enable_flow_logs ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "example" {
  count = var.enable_flow_logs ? 1 : 0
  name   = "${local.common_name}-vpc-flow-logs"
  role   = aws_iam_role.example[count.index].id
  policy = data.aws_iam_policy_document.example[count.index].json
}