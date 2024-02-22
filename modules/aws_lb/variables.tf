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

variable "public_subnets" {
  description = "list of private subnets"
}
variable "instance_type" {}

variable "vpc_id" {}
variable "certificate_arn" {

}
