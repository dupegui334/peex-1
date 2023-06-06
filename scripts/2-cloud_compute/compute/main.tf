#Locals used to use the resources from the networking module
# locals {
#   vpc_id = var.vpc_id
#   public_subnet = var.public_subnet
# }

resource "aws_instance" "ec2-peex" {
  ami           = var.ami
  instance_type = var.instance-type
  key_name               = data.aws_key_pair.ec2-key.key_name
  vpc_security_group_ids = [aws_security_group.app-sg.id]
  subnet_id = var.public_subnet[0] #Need to associate to subnet created so we can create SG in the VPC
  associate_public_ip_address = true

  tags = {
    Name = "PeEx public EC2"
  }
}

data "aws_key_pair" "ec2-key" {
  key_name = "centos-ec2"
}

resource "aws_security_group" "app-sg" {
  name        = "ec2-peex-sg"
  description = "Security group for PeEx EC2"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH connection"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

output "publicip" {
  value = aws_instance.ec2-peex.public_ip
}