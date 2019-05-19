output "db_endpoint" {
  value = "${aws_rds_cluster.this.endpoint}"
}

output "db_security_group_id" {
  value = "${aws_security_group.this.id}"
}

output "db_port" {
  value = "${var.port}"
}
