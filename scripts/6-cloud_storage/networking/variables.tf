variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  type = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_block" {
  type = list(string)
  default = ["10.0.0.0/17"]
}

variable "private_subnet_cidr_block" {
  type = list(string)
  default = ["10.0.128.0/17"]
}

variable "aws-region" {
  type = string
  default = "us-east-1"
}
