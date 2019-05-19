variable "service_name" {
  description = "prefix for resource name, tag"
  default     = "sample"
}

variable "version" {
  description = "version label"
  default     = "0.0.1"
}

variable "db_username" {
  description = "master user name of db"
  default     = "root"
}

variable "db_password" {
  description = "password of db master user"
}

variable "db_port" {
  description = "port of db"
  default     = "3306"
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
    "10.0.2.0/24",
  ]
}

variable "private_web_subnets" {
  description = "cidr of private subnets"
  type        = "list"

  default = [
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
  ]
}

variable "private_app_subnets" {
  description = "cidr of private subnets"
  type        = "list"

  default = [
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
  ]
}

variable "private_db_subnets" {
  description = "cidr of private subnets"
  type        = "list"

  default = [
    "10.1.0.0/24",
    "10.1.1.0/24",
    "10.1.2.0/24",
  ]
  # default = [
  #   "10.0.9.0/24",
  #   "10.0.10.0/24",
  #   "10.0.11.0/24",
  # ]
}

variable "azs" {
  description = "using availability zones"
  type        = "list"

  default = [
    "ap-northeast-2a",
    "ap-northeast-2b",
    "ap-northeast-2c",
  ]
}
