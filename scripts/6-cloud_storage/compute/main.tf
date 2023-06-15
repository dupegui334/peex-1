resource "aws_s3_bucket" "nebo-s3" {
  bucket = "nebo-bucket"

  object_lock_enabled = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }

  tags = {
    Name        = "My nebo bucket"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "nebo-s3-lock" {
  bucket = aws_s3_bucket.nebo-s3.id

  rule {
    default_retention { # The objects can only be deleted after 1 day
      mode = "COMPLIANCE"
      days = 1
    }
  }
}

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

resource "aws_iam_user" "user-1" { 
    name = "user-1"
    tags = {
        Description = "User with Read and write permissions to S3 bucket"
    }
    force_destroy = true # To be able to delete user when destroying resources
}

resource "aws_iam_user" "user-2" { 
    name = "user-2"
    tags = {
        Description = "User with Read only permissions to S3 bucket"
    }
    force_destroy = true # To be able to delete user when destroying resources
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3-read-policy"
  description = "Allows ONLY read access to nebo S3 bucket"

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "",
        Effect: "Allow",
        Action: [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
        ],
        Resource: [
          "arn:aws:s3:::*",
          "arn:aws:s3:::/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "s3_rw_policy" {
  name        = "s3-read-write-policy"
  description = "Allows write and read access to nebo S3 bucket"

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "",
        Effect: "Allow",
        Action: [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListAllMyBuckets",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:getBucketVersioning"
        ],
        Resource: [
          "arn:aws:s3:::*",
          "arn:aws:s3:::/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "s3_read_policy_attachment" {
  user       = aws_iam_user.user-2.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_user_policy_attachment" "s3_read_write_policy_attachment" {
  user       = aws_iam_user.user-1.name
  policy_arn = aws_iam_policy.s3_rw_policy.arn
}