project_name = "enterprise-oracle-data_guard-engineering"

environment = "production"

aws_region = "us-east-1"

availability_zone = "us-east-1a"

availability_zone_secondary = "us-east-1b"

rhel_ami_id = "ami-01251b761bd92b957"

admin_cidr = "72.83.2.51/32"

vpc_cidr = "10.20.0.0/16"

public_subnet_cidr = "10.20.1.0/24"

private_subnet_cidr = "10.20.2.0/24"

private_subnet_cidr_secondary = "10.20.3.0/24"

database_instance_type           = "t3.large"
application_instance_type        = "t3.large"
database_instance_type_secondary = "t3.large"
# application_instance_type_secondary = "t3.large"
# application_instance_type_tertiary  = "t3.large"