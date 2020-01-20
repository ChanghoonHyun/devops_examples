module "vpc" {
  source = "./modules/vpc"
  service_name = var.service_name
  web_vpc_cidr = var.web_vpc_cidr
  db_vpc_cidr = var.db_vpc_cidr
  azs = var.azs
  web_vpc_public_subnets = var.web_vpc_public_subnets
  web_vpc_private_web_subnets = var.web_vpc_private_web_subnets
  web_vpc_privte_app_subnets = var.web_vpc_privte_app_subnets
  db_vpc_private_subnets = var.db_vpc_private_subnets
}

resource "aws_db_parameter_group" "aurora_db_56_parameter_group" {
  name = var.aws_db_parameter_group_name
  family = var.aws_db_parameter_group_family
  description = var.aws_db_parameter_group_description

  tags = {
    Terraform = "true"
    Environment = var.stage
  }
}

resource "aws_rds_cluster_parameter_group" "aurora_56_cluster_parameter_group" {
  name = var.aws_rds_cluster_parameter_group_name
  family = var.aws_rds_cluster_parameter_group_family
  description = var.aws_rds_cluster_parameter_group_description

  tags = {
    Terraform = "true"
    Environment = var.stage
  }
}

module "db" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name = "${var.service_name}-db"
  engine = var.db_engine
  engine_version = var.db_engine_version
  vpc_id = module.vpc.db_vpc_id
  subnets = module.vpc.db_vpc_private_db_subnet_ids
  replica_count = var.db_replica_count
  instance_type = var.db_instance_type
  create_security_group = var.create_security_group
  db_parameter_group_name = aws_db_parameter_group.aurora_db_56_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_56_cluster_parameter_group.id
  skip_final_snapshot = var.skip_final_snapshot

  tags = {
    Terraform = "true"
    Environment = var.stage
  }
}


module "redis" {
  source = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=tags/0.14.0"
  availability_zones = var.azs
  namespace = var.service_name
  stage = var.stage
  name = "${var.service_name}-redis"
  vpc_id = module.vpc.db_vpc_id
  subnets = module.vpc.db_vpc_private_db_subnet_ids
  cluster_size = 1
  instance_type = "cache.t2.micro"
  apply_immediately = true
  automatic_failover_enabled = false
  engine_version = "5.0.6"
  family = "redis5.0"
  at_rest_encryption_enabled = false
  transit_encryption_enabled = false

  tags = {
    Terraform = "true"
    Environment = var.stage
  }
}

resource "aws_s3_bucket" "eb_bucket" {
  bucket = "${var.service_name}-beanstalk"
  force_destroy = var.eb_bucket_force_destroy
  acl = var.eb_bucket_acl

  tags = {
    Terraform = "true"
    Environment = var.stage
  }
}

module "eb_app" {
  source = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=tags/0.3.0"
  description = "elastic_beanstalk_application"
  namespace = var.service_name
  stage = var.stage
  name = var.service_name
  delimiter = "-"

  tags = {
    Terraform = "true"
    Environment = var.stage
  }
}

resource "aws_s3_bucket_object" "source_bucket" {
  source = var.eb_source_s3_object
  bucket = aws_s3_bucket.eb_bucket.id
  key = "${var.service_name}/sample.zip"
}

resource "aws_elastic_beanstalk_application_version" "version" {
  name = module.eb_app.elastic_beanstalk_application_name
  application = module.eb_app.elastic_beanstalk_application_name
  bucket = aws_s3_bucket_object.source_bucket.bucket
  key = aws_s3_bucket_object.source_bucket.key
}

module "eb_app_server_env" {
  source = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=tags/0.17.0"
  namespace = var.service_name
  stage = var.stage
  name = "${var.service_name}-app"
  delimiter = "-"
  description = "server elastic_beanstalk_environment"
  region = var.default_region
  availability_zone_selector = "Any 2"
  version_label = aws_elastic_beanstalk_application_version.version.name

  wait_for_ready_timeout = "10m"
  elastic_beanstalk_application_name = module.eb_app.elastic_beanstalk_application_name
  environment_type = "LoadBalanced"
  loadbalancer_type = "application"
  elb_scheme = "internal"
  tier = "WebServer"
  force_destroy = true

  instance_type = "t2.micro"

  autoscale_min = 1
  autoscale_max = 1
  autoscale_measure_name = "CPUUtilization"
  autoscale_statistic = "Average"
  autoscale_unit = "Percent"
  autoscale_lower_bound = 20
  autoscale_lower_increment = -1
  autoscale_upper_bound = 80
  autoscale_upper_increment = 1

  vpc_id = module.vpc.web_vpc_id
  loadbalancer_subnets = module.vpc.web_vpc_private_app_subnet_ids
  application_subnets = module.vpc.web_vpc_private_app_subnet_ids
  allowed_security_groups = [
    module.vpc.web_vpc_default_security_group_id
  ]

  rolling_update_enabled = true
  rolling_update_type = "Health"
  updating_min_in_service = 0
  updating_max_batch = 1

  healthcheck_url = "/"
  application_port = 80

  solution_stack_name = "64bit Amazon Linux 2018.03 v4.12.0 running Node.js"

  tags = {
    Terraform = "true"
    Environment = var.stage
  }
}

module "eb_app_web_env" {
  source = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=tags/0.17.0"
  namespace = var.service_name
  stage = var.stage
  name = "${var.service_name}-web"
  delimiter = "-"
  description = "server elastic_beanstalk_environment"
  region = var.default_region
  availability_zone_selector = "Any 2"
  version_label = aws_elastic_beanstalk_application_version.version.name

  wait_for_ready_timeout = "10m"
  elastic_beanstalk_application_name = module.eb_app.elastic_beanstalk_application_name
  environment_type = "LoadBalanced"
  loadbalancer_type = "application"
  elb_scheme = "public"
  tier = "WebServer"
  force_destroy = true

  instance_type = "t2.micro"

  autoscale_min = 1
  autoscale_max = 1
  autoscale_measure_name = "CPUUtilization"
  autoscale_statistic = "Average"
  autoscale_unit = "Percent"
  autoscale_lower_bound = 20
  autoscale_lower_increment = -1
  autoscale_upper_bound = 80
  autoscale_upper_increment = 1

  vpc_id = module.vpc.web_vpc_id
  loadbalancer_subnets = module.vpc.web_vpc_public_subnet_ids
  application_subnets = module.vpc.web_vpc_private_web_subnet_ids

  rolling_update_enabled = true
  rolling_update_type = "Health"
  updating_min_in_service = 0
  updating_max_batch = 1

  healthcheck_url = "/"
  application_port = 80

  solution_stack_name = "64bit Amazon Linux 2018.03 v4.12.0 running Node.js"

  tags = {
    Terraform = "true"
    Environment = var.stage
  }
}

resource "aws_dynamodb_table" "basic_dynamodb" {
  name = var.service_name
  billing_mode = "PROVISIONED"
  read_capacity = 1
  write_capacity = 1
  hash_key = "UserId"
  range_key = "GameTitle"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  tags = {
    Terraform = "true"
    Environment = var.stage
  }
}

resource "aws_sqs_queue" "queue" {
  name = var.service_name
  delay_seconds = var.sqs_delay_seconds
  max_message_size = var.sqs_max_message_size
  message_retention_seconds = var.sqs_message_retention_seconds
  receive_wait_time_seconds = var.sqs_receive_wait_time_seconds

  tags = {
    Terraform = "true"
    Environment = var.stage
  }
}

module "lambda" {
  source = "./modules/lambda"

  function_name = var.function_name
  handler = var.handler
  runtime = var.runtime
  source_file = var.source_file
  output_path = var.output_path
}