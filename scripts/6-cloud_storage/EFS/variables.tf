variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_block" {
  type    = list(string)
  default = ["10.0.0.0/17"]
}

variable "ami" {
  default = "ami-0715c1897453cabd1"
}

variable "instance-type" {
  default = "t2.micro"
}

