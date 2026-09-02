################################################################################
# Oracle Database
################################################################################

output "database_private_ip" {

  description = "Oracle Database Private IP"

  value = aws_instance.oracloud_db01.private_ip

}

output "database_instance_id" {

  description = "Oracle Database Instance ID"

  value = aws_instance.oracloud_db01.id

}
