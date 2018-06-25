variable "key_name" {
  description = "The AWS key pair to use for resources"
}
variable "region" {
  description = "AWS region"
  default = "us-west-2"
}
variable "ami" {
  description = "AMI of AWS"
  type = "map"
  default = {
    "us-west-1" = "ami-8d948ced"
    "us-west-2" = "ami-8d948ced"
  }
}
variable "instance_type" {
  description = "The instance type"
  default = "t2_micro"
}

variable "dev_instance_ips" {
  type = "list"
  description = "The IPs to use for our instance"
  default = ["10.0.1.20", "10.0.1.21"]
}

variable "prod_instance_ips" {
  type = "list"
  description = "The IPs to use for our instance"
  default = ["10.0.1.20", "10.0.1.21", "10.0.1.22"]
}

# Local values assign a name to an expression, essentially allowing you to create repeateable function-like values.
locals {
  instances_count =  "${var.environment == "dev" ? length(var.dev_instance_ips) : length(var.prod_instance_ips)}"
}

variable "owner_tag" {
  type = "list"
  description = "Distribute instances between these tags"
  default = ["team1", "team2"]
}

variable "environment" {
  default = "dev"
}