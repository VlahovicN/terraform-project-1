variable "db_name" {}
variable "username" {}
variable "password" {}


variable "rds_sg" {}

variable "db_subnets" {
    type = list(string)
}