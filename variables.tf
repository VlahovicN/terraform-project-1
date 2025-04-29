variable "cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "ami" {
  default = "ami-0e449927258d45bc4"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "bucket_name" {
  default = "html-backup-vlahovic"
}