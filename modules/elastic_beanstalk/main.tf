# run build script
resource "null_resource" "build" {
  provisioner "local-exec" {
    command = "${var.build_command}"
  }

  triggers {
    version_label = "${var.version_label}"
  }
}

# iam for service
data "aws_iam_policy_document" "service_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "service" {
  name               = "${var.service_name}-${var.app_name}-${var.stage}-eb-service-role"
  assume_role_policy = "${data.aws_iam_policy_document.service_policy.json}"
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = "${aws_iam_role.service.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_role_policy_attachment" "enhanced-health" {
  role       = "${aws_iam_role.service.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

# iam for ec2
data "aws_iam_policy_document" "ec2" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "eb_ec2" {
  name               = "${var.service_name}-${var.app_name}-${var.stage}-eb-ec2-role"
  assume_role_policy = "${data.aws_iam_policy_document.ec2.json}"
}

data "aws_iam_policy_document" "ec2_iam_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/elasticbeanstalk*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::beanstalk-*",
      "arn:aws:s3:::beanstalk-*/*",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "eb_ec2" {
  name   = "${var.service_name}-${var.app_name}-${var.stage}-eb-ec2-policy"
  role   = "${aws_iam_role.eb_ec2.id}"
  policy = "${data.aws_iam_policy_document.ec2_iam_policy.json}"
}

# ec2 intance profile
resource "aws_iam_instance_profile" "eb_ec2" {
  name = "${var.service_name}-${var.app_name}-${var.stage}-eb-ec2-role"
  role = "${aws_iam_role.eb_ec2.name}"
}

# source bucket
resource "aws_s3_bucket_object" "source_bucket" {
  source = "${var.bundle}"
  bucket = "${var.bucket}"
  key    = "${var.service_name}/${var.stage}/${var.bundle}"

  depends_on = ["null_resource.build"]
}

# security of loadbalancer
resource "aws_security_group" "lb_sg" {
  name        = "${var.service_name}-${var.app_name}-${var.stage}-lb-sg"
  description = "security groups for ${var.service_name}-${var.app_name}-${var.stage}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${map("Name", "${var.service_name}-${var.app_name}-${var.stage}")}"
}

# security group of beanstalk
resource "aws_security_group" "eb_sg" {
  name        = "${var.service_name}-${var.app_name}-${var.stage}-ec2-sg"
  description = "security groups for ${var.service_name}-${var.app_name}-${var.stage}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${map("Name", "${var.service_name}-${var.app_name}-${var.stage}")}"
}

resource "aws_elastic_beanstalk_application" "this" {
  name        = "${var.service_name}-${var.app_name}"
  description = "application of ${var.service_name}-${var.app_name}"
}

resource "aws_elastic_beanstalk_application_version" "version" {
  name        = "${var.version_label}"
  application = "${aws_elastic_beanstalk_application.this.name}"
  bucket      = "${aws_s3_bucket_object.source_bucket.bucket}"
  key         = "${aws_s3_bucket_object.source_bucket.key}"
}

resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep ${var.sleep_for_wait}"
  }
}

resource "aws_elastic_beanstalk_environment" "this" {
  name                = "${var.service_name}-${var.app_name}-${var.stage}"
  application         = "${aws_elastic_beanstalk_application.this.name}"
  solution_stack_name = "${var.solution_stack_name}"
  cname_prefix        = "${var.service_name}-${var.app_name}-${var.stage}"
  tier                = "${var.tier}"
  version_label       = "${aws_elastic_beanstalk_application_version.version.name}"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "${var.associate_public_ip_address}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", var.ec2_subnets)}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "${var.elb_scheme}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${join(",", var.elb_subnets)}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = "${aws_security_group.lb_sg.id}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = "${aws_security_group.lb_sg.id}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${aws_iam_role.service.name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "${var.deployment_policy}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "${var.stream_logs}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "${var.logs_delete_on_terminate}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "${var.logs_retention_in_days}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "${var.enhanced_reporting_enabled}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "HealthStreamingEnabled"
    value     = "${var.health_streaming_enabled}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "DeleteOnTerminate"
    value     = "${var.health_streaming_delete_on_terminate}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "RetentionInDays"
    value     = "${var.health_streaming_retention_in_days}"
  }

  # auto scaling
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = "${var.autoscale_measure_name}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = "${var.autoscale_statistic}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = "${var.autoscale_unit}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = "${var.autoscale_lower_bound}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerBreachScaleIncrement"
    value     = "${var.autoscale_lower_increment}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = "${var.autoscale_upper_bound}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperBreachScaleIncrement"
    value     = "${var.autoscale_upper_increment}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.autoscale_min}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.autoscale_max}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.eb_ec2.name}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${aws_security_group.eb_sg.id}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.instance_type}"
  }

  depends_on = ["null_resource.wait"]
}

# add rule to db subnet
resource "aws_security_group_rule" "db_ingress" {
  count = "${var.db_connect_enabled == "true" ? 1 : 0}"

  type                     = "ingress"
  from_port                = "${var.db_port}"
  to_port                  = "${var.db_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.eb_sg.id}"
  security_group_id        = "${var.db_security_group_id}"
}

resource "aws_security_group_rule" "db_egress" {
  count = "${var.db_connect_enabled == "true" ? 1 : 0}"

  type                     = "egress"
  from_port                = "${var.db_port}"
  to_port                  = "${var.db_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.eb_sg.id}"
  security_group_id        = "${var.db_security_group_id}"
}
