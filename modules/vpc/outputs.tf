output "vpc_id" {
  value = "${aws_vpc.this.id}"
}

output "db_vpc_id" {
  value = "${aws_vpc.db_vpc.id}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.public.*.id}"
}

output "private_web_subnet_ids" {
  value = "${aws_subnet.private_web.*.id}"
}

output "private_app_subnet_ids" {
  value = "${aws_subnet.private_app.*.id}"
}

output "private_db_subnet_ids" {
  value = "${aws_subnet.private_db.*.id}"
}