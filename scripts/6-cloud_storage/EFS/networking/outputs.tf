#Outputs are defined because they are going to be used for compute modules

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet" {
  description = "Public subnet of the VPC"
  value = aws_subnet.public_subnet.*.id
}

