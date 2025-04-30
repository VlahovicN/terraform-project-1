variable "cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "ami" {
  default = "ami-053b0d53c279acc90"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "bucket_name" {
  default = "html-backup-vlahovic-11224-vrcin"
}

variable "priv_subnet_cidr" {
  default = "10.0.2.0/24"
}
