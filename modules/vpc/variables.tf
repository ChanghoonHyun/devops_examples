variable "service_name" {
  description = "prefix for resource name, tag"
  default     = "sample"
}

variable "vpc_cidr" {
  description = "cidr of vpc"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "cidr of public subnets"
  type        = "list"

  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
  ]
}

variable "private_web_subnets" {
  description = "cidr of private subnets"
  type        = "list"

  default = [
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
}

variable "private_app_subnets" {
  description = "cidr of private subnets"
  type        = "list"

  default = [
    "10.0.4.0/24",
    "10.0.5.0/24",
  ]
}

variable "private_db_subnets" {
  description = "cidr of private subnets"
  type        = "list"

  default = [
    "10.0.6.0/24",
    "10.0.7.0/24",
  ]
}

variable "azs" {
  description = "using availability zones"
  type        = "list"

  default = [
    "ap-northeast-2a",
    "ap-northeast-2c",
  ]
}
