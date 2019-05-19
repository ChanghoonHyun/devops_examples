data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = "${var.monitoring_interval > 0 ? 1 : 0}"

  name               = "rds-enhanced-monitoring-${var.service_name}"
  assume_role_policy = "${data.aws_iam_policy_document.monitoring_rds_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = "${var.monitoring_interval > 0 ? 1 : 0}"

  role       = "${aws_iam_role.rds_enhanced_monitoring.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_subnet_group" "this" {
  name        = "${var.service_name}-db-subnet-group"
  description = "subnet group for aurora cluster"
  subnet_ids  = ["${var.db_subnet_ids}"]

  tags = "${map("Name", "${var.service_name}")}"
}

resource "aws_security_group" "this" {
  name_prefix = "${var.service_name}-db-"
  vpc_id      = "${var.vpc_id}"

  tags = "${map("Name", "${var.service_name}")}"
}

resource "aws_rds_cluster" "this" {
  cluster_identifier              = "${var.service_name}"
  engine                          = "${var.engine}"
  engine_mode                     = "${var.engine_mode}"
  engine_version                  = "${var.engine_version}"
  database_name                   = "${var.database_name}"
  master_username                 = "${var.master_username}"
  master_password                 = "${var.master_password}"
  skip_final_snapshot             = "${var.skip_final_snapshot}"
  backup_retention_period         = "${var.backup_retention_period}"
  preferred_backup_window         = "${var.preferred_backup_window}"
  preferred_maintenance_window    = "${var.preferred_maintenance_window}"
  db_subnet_group_name            = "${aws_db_subnet_group.this.name}"
  vpc_security_group_ids          = ["${aws_security_group.this.id}"]
  db_cluster_parameter_group_name = "${var.db_cluster_parameter_group_name}"
  enabled_cloudwatch_logs_exports = "${var.enabled_cloudwatch_logs_exports}"

  tags = "${map("Name", "${var.service_name}")}"
}

resource "aws_rds_cluster_instance" "this" {
  count = "${var.instance_count}"

  identifier                   = "${var.service_name}-${count.index + 1}"
  cluster_identifier           = "${aws_rds_cluster.this.id}"
  engine                       = "${var.engine}"
  engine_version               = "${var.engine_version}"
  instance_class               = "${var.instance_type}"
  publicly_accessible          = "${var.publicly_accessible}"
  db_subnet_group_name         = "${aws_db_subnet_group.this.name}"
  db_parameter_group_name      = "${var.db_parameter_group_name}"
  preferred_maintenance_window = "${var.preferred_maintenance_window}"
  monitoring_role_arn          = "${join("", aws_iam_role.rds_enhanced_monitoring.*.arn)}"
  monitoring_interval          = "${var.monitoring_interval}"
  auto_minor_version_upgrade   = "${var.auto_minor_version_upgrade}"
  promotion_tier               = "${count.index + 1}"
  performance_insights_enabled = "${var.performance_insights_enabled}"

  tags = "${map("Name", "${var.service_name}")}"
}
