variable "ami" {
    default = "ami-0715c1897453cabd1"
}

variable "instance-type" {
    default = "t2.micro"
}

variable "vpc_id" {
    description = "VPC ID"
}

variable "public_subnet" {
    description = "Public subnet of VPC"
}

variable "private_subnet" {
    description = "Private subnet of VPC"
}
