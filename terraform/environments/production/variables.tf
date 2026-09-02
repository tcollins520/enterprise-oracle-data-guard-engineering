################################################################################
# Project
################################################################################

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Deployment Environment"
  type        = string
}

################################################################################
# AWS
################################################################################

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
}

variable "availability_zone_secondary" {
  description = "Secondary Availability Zone for the standby database"
  type        = string
}

################################################################################
# Red Hat Enterprise Linux
################################################################################

variable "rhel_ami_id" {
  description = "RHEL 8 AMI ID"
  type        = string
}

################################################################################
# Networking
################################################################################

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private Subnet CIDR"
  type        = string
}


variable "private_subnet_cidr_secondary" {
  description = "Secondary Private Subnet CIDR"
  type        = string
}

################################################################################
# Compute
################################################################################

variable "database_instance_type" {
  description = "Oracle Database EC2 Instance Type"
  type        = string
}

variable "database_instance_type_secondary" {
  description = "EC2 instance type for the secondary Oracle Database server"
  type        = string
  default     = "t3.large"
}

variable "application_instance_type" {
  description = "Oracle WebLogic EC2 Instance Type"
  type        = string
}

variable "application_instance_type_secondary" {
  description = "EC2 instance type for the secondary WebLogic application server"
  type        = string
  default     = "t3.large"
}

variable "application_instance_type_tertiary" {
  description = "EC2 instance type for the third WebLogic application server"
  type        = string
  default     = "t3.large"
}


################################################################################
# Admin Access
################################################################################

variable "admin_cidr" {

  description = "Administrator Public IP"

  type = string

}