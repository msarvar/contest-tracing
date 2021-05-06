locals {
  vpcs   = toset(["a", "b", "c", "d", "e", "f"])
  region = "us-east-1"
}

module "vpc" {
  for_each = local.vpcs
  source   = "terraform-aws-modules/vpc/aws"

  name = "vpc${each.value}"
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  create_database_subnet_group = true
}

module "security_group" {
  for_each = local.vpcs
  source   = "terraform-aws-modules/security-group/aws"

  name        = "secgrp{each.value}"
  description = "Complete SqlServer example security group"
  vpc_id      = module.vpc[each.value].vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "SqlServer access from within VPC"
      cidr_blocks = module.vpc[each.value].vpc_cidr_block
    },
  ]

}

################################################################################
# RDS Module
################################################################################

module "db" {
  for_each = local.vpcs
  source   = "terraform-aws-modules/rds/aws"

  identifier = "rds${each.value}"

  engine               = "sqlserver-ex"
  engine_version       = "15.00.4073.23.v1"
  family               = "sqlserver-ex-15.0" # DB parameter group
  major_engine_version = "15.00"             # DB option group
  instance_class       = "db.t3.large"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  name                   = "db${each.value}"
  username               = "complete_mssql"
  create_random_password = true
  random_password_length = 12
  port                   = 1433

  multi_az               = false
  subnet_ids             = module.vpc[each.value].database_subnets
  vpc_security_group_ids = [module.security_group[each.value].security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["error"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60

  options                   = []
  create_db_parameter_group = false
  license_model             = "license-included"
  timezone                  = "GMT Standard Time"
  character_set_name        = "Latin1_General_CI_AS"
}
