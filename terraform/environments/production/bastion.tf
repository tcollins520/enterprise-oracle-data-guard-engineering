################################################################################
# Amazon Linux 2023 AMI
################################################################################

data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

}

################################################################################
# Bastion Host
################################################################################

resource "aws_instance" "bastion" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public.id

  associate_public_ip_address = true

  key_name = data.aws_key_pair.oracle_dg.key_name

  iam_instance_profile = aws_iam_instance_profile.oracle.name

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  root_block_device {

    volume_size = 8
    volume_type = "gp3"

  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "tinacloud-bastion01"
      Role = "JumpHost"
    }
  )
}