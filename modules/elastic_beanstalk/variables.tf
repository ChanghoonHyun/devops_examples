variable "service_name" {
  description = "prefix for resource name, tag"
  default     = "sample"
}

variable "app_name" {
  description = "prefix for resource name, tag"
  default     = "app1"
}

variable "stage" {
  description = "ex 'prod', 'dev', 'stage', 'test'"
  default     = "dev"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "instances type"
}

variable "vpc_id" {
  description = "id of vpc"
}

variable "tier" {
  description = "ex 'WebServer', 'Worker'"
  default     = "WebServer"
}

variable "solution_stack_name" {
  description = "http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html"
  default     = "64bit Amazon Linux 2018.03 v4.8.3 running Node.js"
}

variable "elb_scheme" {
  description = "public or internal"
  default     = "public"
}

variable "elb_subnets" {
  type        = "list"
  description = "List of elb subnets to place Elastic Load Balancer"
}

variable "ec2_subnets" {
  type        = "list"
  description = "List of ec2 subnets to place EC2 instances"
}

variable "associate_public_ip_address" {
  description = "launch instances with public ip"
  default     = "false"
}

variable "deployment_policy" {
  description = "ex 'Immutable', 'Rolling'"
  default     = "Rolling"
}

variable "stream_logs" {
  description = "ex 'true', 'false'"
  default     = "true"
}

variable "logs_delete_on_terminate" {
  description = "ex 'true', 'false'"
  default     = "true"
}

variable "logs_retention_in_days" {
  description = "retention days of cloudwatch logs"
  default     = 30
}

variable "enhanced_reporting_enabled" {
  description = "ex 'enhanced', 'basic'"
  default     = "enhanced"
}

variable "health_streaming_enabled" {
  description = "ex 'true', 'false'"
  default     = "true"
}

variable "health_streaming_delete_on_terminate" {
  description = "ex 'true', 'false'"
  default     = "true"
}

variable "health_streaming_retention_in_days" {
  description = "retention days of cloudwatch health logs"
  default     = 30
}

variable "autoscale_measure_name" {
  description = "metric name of auto scaling "
  default     = "CPUUtilization"
}

variable "autoscale_statistic" {
  description = "statistic of austo scaling"
  default     = "Average"
}

variable "autoscale_unit" {
  description = "unit of metric measurement"
  default     = "Percent"
}

variable "autoscale_lower_bound" {
  description = "minimum metric to remove instance"
  default     = "20"
}

variable "autoscale_lower_increment" {
  description = "instance count to remove by auto scalaing "
  default     = "-1"
}

variable "autoscale_upper_bound" {
  description = "maximum metric to add instance"
  default     = "80"
}

variable "autoscale_upper_increment" {
  description = "instance count to add instance"
  default     = "1"
}

variable "autoscale_min" {
  description = "minumum instances count"
  default     = "2"
}

variable "autoscale_max" {
  description = "maximum instances count"
  default     = "4"
}

variable "build_command" {
  description = "command of build & packaging"
}

variable "bundle" {
  description = "bundle path of application"
}

variable "bucket" {
  description = "version version store"
}

variable "version_label" {
  description = "version label"
}

variable "db_connect_enabled" {
  description = "enable connect with db"
  default     = "false"
}

variable "db_security_group_id" {
  description = "security group id of db to add to inbound, outbound"
  default     = ""
}

variable "db_port" {
  description = "port number of db"
  default     = "3306"
}

variable sleep_for_wait {
  description = "sleep interval for dependency"
  default = "0"
}
