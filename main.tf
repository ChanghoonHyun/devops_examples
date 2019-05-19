module "vpc" {
  source              = "./modules/vpc"
  service_name        = "${var.service_name}"
  vpc_cidr            = "${var.vpc_cidr}"
  azs                 = "${var.azs}"
  public_subnets      = "${var.public_subnets}"
  private_web_subnets = "${var.private_web_subnets}"
  private_app_subnets = "${var.private_app_subnets}"
  private_db_subnets  = "${var.private_db_subnets}"
}

module "db" {
  source          = "./modules/aurora_mysql"
  service_name    = "${var.service_name}"
  vpc_id          = "${module.vpc.db_vpc_id}"
  db_subnet_ids   = "${module.vpc.private_db_subnet_ids}"
  instance_count  = "1"
  master_username = "${var.db_username}"
  master_password = "${var.db_password}"
  port            = "${var.db_port}"
}

resource "aws_s3_bucket" "eb_bucket" {
  bucket        = "${var.service_name}-beanstalk"
  force_destroy = true
  acl           = "private"
}

module "app_eb" {
  source               = "./modules/elastic_beanstalk"
  service_name         = "${var.service_name}"
  app_name             = "app"
  vpc_id               = "${module.vpc.vpc_id}"
  elb_scheme           = "internal"
  elb_subnets          = "${module.vpc.private_app_subnet_ids}"
  ec2_subnets          = "${module.vpc.private_app_subnet_ids}"
  db_connect_enabled   = "true"
  db_security_group_id = "${module.db.db_security_group_id}"
  db_port              = "${module.db.db_port}"
  build_command        = "./sample_apps/app/build.sh ./sample_apps/app ${var.version} ${module.db.db_endpoint} ${var.db_username} ${var.db_password} ${var.db_port}"
  bundle               = "sample_apps/app-${var.version}.zip"
  bucket               = "${aws_s3_bucket.eb_bucket.id}"
  version_label        = "${var.version}"
  sleep_for_wait       = "300"
}

module "web_eb" {
  source        = "./modules/elastic_beanstalk"
  service_name  = "${var.service_name}"
  app_name      = "web"
  vpc_id        = "${module.vpc.vpc_id}"
  elb_scheme    = "public"
  elb_subnets   = "${module.vpc.public_subnet_ids}"
  ec2_subnets   = "${module.vpc.private_web_subnet_ids}"
  build_command = "./sample_apps/web/build.sh ./sample_apps/web ${var.version} ${module.app_eb.eb_cname}"
  bundle        = "sample_apps/web-${var.version}.zip"
  bucket        = "${aws_s3_bucket.eb_bucket.id}"
  version_label = "${var.version}"
}
