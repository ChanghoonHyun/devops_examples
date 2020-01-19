service_name = "sample"
default_region = "ap-northeast-2"
web_vpc_cidr = "10.0.0.0/16"
db_vpc_cidr = "10.1.0.0/16"
azs = [
  "ap-northeast-2a",
  "ap-northeast-2b"
]
web_vpc_public_subnets = [
  "10.0.0.0/24",
  "10.0.1.0/24",
]

web_vpc_private_web_subnets = [
  "10.0.3.0/24",
  "10.0.4.0/24",
]

web_vpc_privte_app_subnets = [
  "10.0.6.0/24",
  "10.0.7.0/24",
]

db_vpc_private_subnets = [
  "10.1.0.0/24",
  "10.1.1.0/24",
]

db_engine = "aurora"
db_engine_version = "5.6.10a"
db_replica_count = 0
db_instance_type = "db.t2.small"
create_security_group = true
skip_final_snapshot = true
eb_bucket_force_destroy = true
eb_bucket_acl = "private"


