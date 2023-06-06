resource "aws_instance" "ec2-priv" { # EC2 allocated on private subnet
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

resource "aws_instance" "bastion" { # Bastion host to reach ec2 on private subnet
  ami           = var.ami
  instance_type = var.instance-type
  key_name               = data.aws_key_pair.ec2-key.key_name
  vpc_security_group_ids = [aws_security_group.sg-bastion.id]
  subnet_id = var.public_subnet[0] #Need to associate to subnet created so we can create SG inside the VPC
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ssm-instance-role.name


  tags = {
    Name = "bastion-host" # Tag needed so IAM bastion user can reach that resource
  }
}

data "aws_key_pair" "ec2-key" {
  key_name = "centos-ec2"
}

resource "aws_security_group" "sg-bastion" {
  name        = "bastion-sg"
  description = "Security group for bastion"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH connection"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https connection"
    from_port   = 443
    to_port     = 443
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
    cidr_blocks = ["10.0.0.0/17"] #Allow public VM in public subnet of the VPC to ssh it.
  }

  ingress {
    description = "ICMP" #All ICMP
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/17"] #Allow public VM in public subnet of the VPC to ping it.
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_iam_user" "bastion-user" { 
    name = "bastion-user"
    tags = {
        Description = "User used to access EC2 for Peex"
    }
    force_destroy = true # To be able to delete user when destroying resources
}

resource "aws_iam_role" "ssm-ec2-role" { # Role created for ec2 instance
    name = "SSMFullAccess"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action : "sts:AssumeRole",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                Effect   = "Allow"
            }
        ]
    })
}

resource "aws_iam_policy" "ec2-bastion-policy" { # Policy to attach to IAM bastion user
  name        = "EC2-access-bastion-IAM-user"
  description = "Allows access to EC2 instances via SSM to IAM bastion user"

  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": [
                "ec2:RebootInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeSecurityGroups"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/Name": [
                        "bastion-host" # Can act only on ec2 instances with this tag
                    ]
                }
            }
        },
        {
            "Sid": "Statement2",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "cloudwatch:DescribeAlarms",
                "ssm:StartSession",
                "ssm:DescribeInstanceInformation",
                "ssm:GetConnectionStatus"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" { #Attach SSM full access policy to the role created
  role       = aws_iam_role.ssm-ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_user_policy_attachment" "bastion_user_policy_attachment" { #Attach policy to IAM bastion-user to interact on ec2 resources
  user       = aws_iam_user.bastion-user.name
  policy_arn = aws_iam_policy.ec2-bastion-policy.arn
}

resource "aws_iam_instance_profile" "ssm-instance-role" { #Resource used to attach role to ec2 instance
  name  = "ssm-instance-role"
  role = aws_iam_role.ssm-ec2-role.name
}