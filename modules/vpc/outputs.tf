output "web_vpc_id" {
  value = aws_vpc.this.id
}

output "db_vpc_id" {
  value = aws_vpc.db_vpc.id
}

output "web_vpc_public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "web_vpc_private_web_subnet_ids" {
  value = aws_subnet.private_web.*.id
}

output "web_vpc_private_app_subnet_ids" {
  value = aws_subnet.private_app.*.id
}

output "web_vpc_default_security_group_id" {
  value = concat(aws_vpc.this.*.default_security_group_id, [""])[0]
}

output "db_vpc_private_db_subnet_ids" {
  value = aws_subnet.private_db.*.id
}

output "db_vpc_default_security_group_id" {
  value = concat(aws_vpc.db_vpc.*.default_security_group_id, [""])[0]
}