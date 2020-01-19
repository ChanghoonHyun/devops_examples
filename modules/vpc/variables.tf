variable "service_name" {
  description = "prefix for resource name, tag"
  default = "sample"
}

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