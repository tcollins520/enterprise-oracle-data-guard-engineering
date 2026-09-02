################################################################################
# Oracle Database Security Group
################################################################################

resource "aws_security_group" "oracle" {

  name        = "${var.project_name}-oracle-sg"
  description = "Security Group for Oracle Database and WebLogic"
  vpc_id      = aws_vpc.oracle.id

  ###########################################################################
  # SSH From Bastion
  ###########################################################################

  ingress {

    description = "SSH from Bastion"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    security_groups = [
      aws_security_group.bastion.id
    ]

  }

  ###########################################################################
  # Oracle Listener
  ###########################################################################

  ingress {

    description = "Oracle Listener"

    from_port = 1521
    to_port   = 1521

    protocol = "tcp"

    cidr_blocks = [
      var.vpc_cidr
    ]

  }

  ###########################################################################
  # Outbound
  ###########################################################################

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-oracle-sg"
    }
  )

}

################################################################################
# Oracle WebLogic Security Group
################################################################################

resource "aws_security_group" "weblogic" {

  name        = "${var.project_name}-weblogic-sg"
  description = "Oracle WebLogic Application Security Group"
  vpc_id      = aws_vpc.oracle.id

  ###########################################################################
  # SSH From Bastion
  ###########################################################################

  ingress {

    description = "SSH from Bastion"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    security_groups = [
      aws_security_group.bastion.id
    ]

  }

  ###########################################################################
  # WebLogic Administration Console
  ###########################################################################

  ingress {

    description = "WebLogic Administration Console"

    from_port = 7001
    to_port   = 7001

    protocol = "tcp"

    cidr_blocks = [
      var.vpc_cidr
    ]

  }

  ###########################################################################
  # Node Manager
  ###########################################################################

  ingress {

    description = "Node Manager"

    from_port = 5556
    to_port   = 5556

    protocol = "tcp"

    cidr_blocks = [
      var.vpc_cidr
    ]

  }

  ###########################################################################
  # Outbound
  ###########################################################################

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-weblogic-sg"
    }
  )

}

################################################################################
# Bastion Security Group
################################################################################

resource "aws_security_group" "bastion" {

  name        = "${var.project_name}-bastion-sg"
  description = "Bastion Host Security Group"
  vpc_id      = aws_vpc.oracle.id

  ###########################################################################
  # SSH From Your Laptop
  ###########################################################################

  ingress {

    description = "SSH"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    cidr_blocks = [
      var.admin_cidr
    ]

  }

  ###########################################################################
  # Outbound
  ###########################################################################

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  tags = merge(
    local.common_tags,
    {
      Name = "bastion01-sg"
    }
  )

}

################################################################################
# VPC Endpoint Security Group
################################################################################

resource "aws_security_group" "vpce" {

  name        = "${var.project_name}-vpce-sg"
  description = "Security Group for VPC Interface Endpoints"
  vpc_id      = aws_vpc.oracle.id

  ###########################################################################
  # HTTPS From VPC
  ###########################################################################

  ingress {

    description = "HTTPS"

    from_port = 443
    to_port   = 443

    protocol = "tcp"

    cidr_blocks = [
      var.vpc_cidr
    ]

  }

  ###########################################################################
  # Outbound
  ###########################################################################

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  tags = merge(
    local.common_tags,
    {
      Name = "vpce-sg"
    }
  )

}