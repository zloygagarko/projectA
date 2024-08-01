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
  default = "ami-00db8dadb36c9815e"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "Vlad1"
}

# variable "security_group_names" {
#   default = ""
# }

# variable "subnet_id" {
#   description = "The subnet ID to associate with the instance"
#   type        = string
# }

# variable "instance_name" {
#   description = "The name tag to apply to the instance"
#   type        = string
# }

# variable "instance_count" {
#   description = "The number of instances to launch"
#   type        = number
# }

#==========================Sec_group_vars=============================

variable "sec_group_name" {
  default = "allow_http_https"
}