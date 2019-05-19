variable "service_name" {
  description = "prefix for resource name, tag"
  default     = "sample"
}

variable "vpc_id" {
  description = "id of vpc"
}

variable "db_subnet_ids" {
  type        = "list"
  description = "subnet ids for db"
}

variable "allowed_security_groups" {
  description = "list of security group to allow"
  default     = []
}

variable "allowed_security_groups_count" {
  description = "length of allowed security groups"
  default     = 0
}

variable "engine" {
  description = "ex 'aurora', 'aurora-mysql' or 'aurora-postgresql'"
  default     = "aurora"
}

variable "engine_mode" {
  description = "ex global, parallelquery, provisioned, serverless"
  default     = "provisioned"
}

variable "engine_version" {
  description = "aurora engine version"
  default     = "5.6.10a"
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  default     = "dbname"
}

variable "master_username" {
  description = "Master DB username"
  default     = "root"
}

variable "master_password" {
  description = "Master DB password"
  default     = "1234qwer"
}

variable "backup_retention_period" {
  description = "keep backup sapshots"
  default     = "7"
}

variable "preferred_backup_window" {
  description = "when to backup snapshot"
  default     = "00:00-01:00"
}

variable "preferred_maintenance_window" {
  description = "when to perform maintenance"
  default     = "sun:03:00-sun:04:00"
}

variable "db_cluster_parameter_group_name" {
  description = "the name of a DB Cluster parameter group to use"
  default     = "default.aurora5.6"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "list of cloudwatch logs"
  type        = "list"
  default     = ["audit", "error", "general", "slowquery"]
}

variable "instance_count" {
  description = "count of replica"
  default     = "1"
}

variable "instance_type" {
  description = "instance type to use"
  default     = "db.t3.small"
}

variable "publicly_accessible" {
  description = "DB have a public ip address"
  default     = "false"
}

variable "db_parameter_group_name" {
  description = "name of DB parameter group"
  default     = "default.aurora5.6"
}

variable "monitoring_interval" {
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected"
  default     = 0
}

variable "auto_minor_version_upgrade" {
  description = "Determines whether minor engine upgrades will be performed automatically in the maintenance window"
  default     = "true"
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not."
  default     = "false"
}

variable "skip_final_snapshot" {
  description = "skip final snapshot"
  default     = "true"
}

variable "port" {
  description = "port of db"
  default     = "3306"
}
