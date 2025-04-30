variable "cidr" {
  default = "10.0.0.0/16"
}

variable "subnet1_cidr" {
  default = "10.0.1.0/24"
}

variable "subnet2_cidr" {
  default = "10.0.3.0/24"
}

variable "ami" {
  default = "ami-053b0d53c279acc90"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "bucket_name" {
  default = "html-backup-vlahovic-11224-vcrn1"
}

variable "priv_subnet_cidr" {
  default = "10.0.2.0/24"
}
