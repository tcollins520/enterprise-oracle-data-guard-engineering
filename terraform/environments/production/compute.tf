################################################################################
# Oracle Database Server 01 (RHEL 8)
################################################################################

resource "aws_instance" "oracloud_db01" {

  ami           = var.rhel_ami_id
  instance_type = var.database_instance_type

  key_name = data.aws_key_pair.oracle_dg.key_name

  subnet_id = aws_subnet.private.id

  vpc_security_group_ids = [
    aws_security_group.oracle.id
  ]

  iam_instance_profile = aws_iam_instance_profile.oracle.name

  associate_public_ip_address = false

  monitoring = true

  user_data_replace_on_change = true

  user_data = file("${path.module}/userdata.sh")

  root_block_device {
    volume_size = 120
    volume_type = "gp3"
    encrypted   = true

    tags = merge(
      local.common_tags,
      {
        Name = "oracloud-db01-root"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "oracloud-db01"
      Role = "Database"
      OS   = "RHEL8"
    }
  )
}



################################################################################
# Oracle Database Physical Standby Server 02 (RHEL 8)
################################################################################

resource "aws_instance" "oracloud_db02" {

  ami           = var.rhel_ami_id
  instance_type = var.database_instance_type_secondary

  key_name = data.aws_key_pair.oracle_dg.key_name

  subnet_id = aws_subnet.private_secondary.id

  vpc_security_group_ids = [
    aws_security_group.oracle.id
  ]

  iam_instance_profile = aws_iam_instance_profile.oracle.name

  associate_public_ip_address = false

  monitoring = true

  user_data_replace_on_change = true

  user_data = file("${path.module}/userdata.sh")

  root_block_device {
    volume_size = 120
    volume_type = "gp3"
    encrypted   = true

    tags = merge(
      local.common_tags,
      {
        Name = "oracloud-db02-root"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "oracloud-db02"
      Role = "Database"
      OS   = "RHEL8"
    }
  )
}
