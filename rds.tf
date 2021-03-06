resource random_string "rds_apps_passowrd" {
  length  = 34
  special = false
}

resource aws_db_instance "default" {
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  max_allocated_storage   = var.max_allocated_storage
  engine                  = var.snapshot_identifier == "" ? var.engine : null
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  name                    = var.name
  backup_retention_period = var.backup_retention_period
  identifier              = var.identifier != "" ? var.identifier : null
  username                = var.username
  password                = random_string.rds_apps_passowrd.result
  parameter_group_name    = aws_db_parameter_group.default.id
  vpc_security_group_ids  = var.vpc_security_group_ids
  apply_immediately       = var.apply_immediately
  skip_final_snapshot     = var.skip_final_snapshot
  snapshot_identifier     = var.snapshot_identifier != "" ? var.snapshot_identifier : null
  deletion_protection     = var.deletion_protection
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = try(var.kms_key_id, null)
  db_subnet_group_name    = "${var.account_name}-dbsubnet" # Created as part of network stack
}

resource aws_db_parameter_group "default" {
  name   = var.parameter_group_name != "" ? var.parameter_group_name : null
  family = var.family

  parameter {
    name  = "sql_mode"
    value = "NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
  }
}

resource aws_ssm_parameter "rds_password" {
  name        = "/rds/${var.identifier}/password"
  description = "RDS Password"
  type        = "SecureString"
  value       = random_string.rds_apps_passowrd.result

  lifecycle {
    ignore_changes = [value]
  }
}

resource aws_ssm_parameter "rds_user" {
  name        = "/rds/${var.identifier}/user"
  description = "RDS User"
  type        = "SecureString"
  value       = var.username
}

resource aws_ssm_parameter "rds_endpoint" {
  name        = "/rds/${var.identifier}/endpoint"
  description = "RDS Endpoint"
  type        = "String"
  value       = aws_db_instance.default.endpoint
}

resource aws_ssm_parameter "rds_address" {
  name        = "/rds/${var.identifier}/address"
  description = "RDS Address"
  type        = "String"
  value       = aws_db_instance.default.address
}

resource aws_ssm_parameter "rds_name" {
  name        = "/rds/${var.identifier}/name"
  description = "RDS DB Name"
  type        = "String"
  value       = aws_db_instance.default.name
}

