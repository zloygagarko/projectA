#==================================VPS vars==================================================
variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "env" {
    default = "dev"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.11.0/24",
    "10.0.22.0/24",
    "10.0.33.0/24"
  ]
}

#==============================EC2_vars===============================================

variable "launch_template_name" {
  default = "rds_work_template"
}

variable "image_id" {
  default = "ami-0a31f06d64a91614b"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "Vlad1"
}

variable "r53_zone_id"{
  default = "Z043439638MBO06EJFACR"
}

#==========================Sec_group_vars=============================


