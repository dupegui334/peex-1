#Locals used to use the resources from the networking module
# locals {
#   vpc_id = var.vpc_id
#   public_subnet = var.public_subnet
# }

resource "aws_instance" "ec2-priv" {
  ami           = var.ami
  instance_type = var.instance-type
  key_name               = data.aws_key_pair.ec2-key.key_name
  vpc_security_group_ids = [aws_security_group.vm-sg-priv.id]
  subnet_id = var.private_subnet[0] #Need to associate to subnet created so we can create SG in the VPC
  associate_public_ip_address = false

  tags = {
    Name = "VM1-priv"
  }
}

resource "aws_instance" "ec2-pub" {
  ami           = var.ami
  instance_type = var.instance-type
  key_name               = data.aws_key_pair.ec2-key.key_name
  vpc_security_group_ids = [aws_security_group.vm-sg-pub.id]
  subnet_id = var.public_subnet[0] #Need to associate to subnet created so we can create SG in the VPC
  associate_public_ip_address = true

  tags = {
    Name = "VM2-pub"
  }
}

data "aws_key_pair" "ec2-key" {
  key_name = "centos-ec2"
}

resource "aws_security_group" "vm-sg-pub" {
  name        = "VM-sg-pub"
  description = "Security group for VM pub"
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

resource "aws_security_group" "vm-sg-priv" {
  name        = "VM-sg-priv"
  description = "Security group for VM priv"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH connection"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/17"]
  }

  ingress {
    description = "ICMP"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/17"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
