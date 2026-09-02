################################################################################
# Systems Manager Endpoint
################################################################################

resource "aws_vpc_endpoint" "ssm" {

  vpc_id = aws_vpc.oracle.id

  service_name = "com.amazonaws.${var.aws_region}.ssm"

  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private.id
  ]

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-ssm-endpoint"
    }
  )

}

################################################################################
# EC2 Messages Endpoint
################################################################################

resource "aws_vpc_endpoint" "ec2messages" {

  vpc_id = aws_vpc.oracle.id

  service_name = "com.amazonaws.${var.aws_region}.ec2messages"

  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private.id
  ]

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-ec2messages-endpoint"
    }
  )

}

################################################################################
# SSM Messages Endpoint
################################################################################

resource "aws_vpc_endpoint" "ssmmessages" {

  vpc_id = aws_vpc.oracle.id

  service_name = "com.amazonaws.${var.aws_region}.ssmmessages"

  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private.id
  ]

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-ssmmessages-endpoint"
    }
  )

}