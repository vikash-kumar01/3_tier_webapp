
variable "region" {
  description = "Enter the region to deploy your aws resources"
}

variable "stackname" {}
variable "environment" {}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_1" {
  description = "CIDR block for public subnet 1"
  type        = string
}

variable "public_subnet_cidr_2" {
  description = "CIDR block for public subnet 2"
  type        = string
}


variable "private_subnet_cidr_1" {
  description = "CIDR block for private subnet 1"
  type        = string
}

variable "private_subnet_cidr_2" {
  description = "CIDR block for private subnet 3"
  type        = string
}

variable "private_subnet_cidr_3" {
  description = "CIDR block for private subnet 4"
  type        = string
}

variable "private_subnet_cidr_4" {
  description = "CIDR block for private subnet 2"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "key_name" {
  description = "key pair name for the ec2 instances"
}

variable "min_instances" {
  description = "Minimum number of instances in Auto Scaling Group"
}

variable "max_instances" {
  description = "Maximum number of instances in Auto Scaling Group"
}

variable "desired_capacity" {
  description = "Desired capacity of Auto Scaling Group"
}

variable "instance_type" {}
variable "certificate_arn" {

}
