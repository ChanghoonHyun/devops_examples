variable "service_name" {
  description = "prefix for resource name, tag"
  default = "sample"
}

variable "stage" {}

variable "web_vpc_cidr" {
  description = "cidr of vpc"
}

variable "db_vpc_cidr" {
  description = "cidr of vpc"
}

variable "web_vpc_public_subnets" {
  description = "cidr of public subnets"
  type = list(string)
}

variable "web_vpc_private_web_subnets" {
  description = "cidr of private subnets"
  type = list(string)
}

variable "web_vpc_privte_app_subnets" {
  description = "cidr of private subnets"
  type = list(string)
}

variable "db_vpc_private_subnets" {
  description = "cidr of private subnets"
  type = list(string)
}

variable "azs" {
  description = "using availability zones"
  type = list(string)
}

variable "default_region" {
  default = "ap-northeast-2"
}

variable "db_engine" {
  description = "engine"
}

variable "db_engine_version" {
  description = "engine version"
}

variable "db_replica_count" {
  description = "count of aurora replica"
}

variable "db_instance_type" {
  description = "instance type of aurora"
}

variable "create_security_group" {
  description = "create sg"
}

variable "skip_final_snapshot" {
  description = "skip final snapshot when delete db cluster"
}

variable "eb_bucket_force_destroy" {
  description = "force s3 destroy"
  type = bool
}

variable "eb_bucket_acl" {
  description = "acl of bucket"
}

variable "eb_source_s3_object" {}

variable "aws_db_parameter_group_name" {}
variable "aws_db_parameter_group_family" {}
variable "aws_db_parameter_group_description" {}
variable "aws_rds_cluster_parameter_group_name" {}
variable "aws_rds_cluster_parameter_group_family" {}
variable "aws_rds_cluster_parameter_group_description" {}

variable "sqs_delay_seconds" {}
variable "sqs_max_message_size" {}
variable "sqs_message_retention_seconds" {}
variable "sqs_receive_wait_time_seconds" {}

variable "function_name" {}
variable "handler" {}
variable "runtime" {}
variable "source_file" {}
variable "output_path" {}
