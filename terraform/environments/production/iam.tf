################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "oracle_ec2" {

  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Action = "sts:AssumeRole"

        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"

        }

      }

    ]

  })

  tags = local.common_tags

}

################################################################################
# Attach Amazon SSM Managed Policy
################################################################################

resource "aws_iam_role_policy_attachment" "ssm" {

  role = aws_iam_role.oracle_ec2.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

################################################################################
# EC2 Instance Profile
################################################################################

resource "aws_iam_instance_profile" "oracle" {

  name = "${var.project_name}-instance-profile"

  role = aws_iam_role.oracle_ec2.name

}