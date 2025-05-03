variable "vpc_id" {}

variable "alb_sg_id" {}

variable "subnets" {
    type = list(string)
}

