resource "aws_efs_file_system" "nebo-efs" {
  creation_token = "nebo-efs"
  encrypted = true

  tags = {
    Name = "nebo-efs"
  }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.nebo-efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "mount_efs" {
  file_system_id = aws_efs_file_system.nebo-efs.id
  subnet_id = var.public_subnet[0]
  security_groups = [aws_security_group.sg-nebo-efs.id]
}

resource "aws_iam_user" "user-1" { 
    name = "user-1"
    tags = {
        Description = "User with Read and write permissions to EFS"
    }
    force_destroy = true # To be able to delete user when destroying resources
}

resource "aws_iam_policy" "EFS_rw_policy" { # Policy for user with read/write access
  name        = "EFS-read-write-policy"
  description = "Allows write and read access to EFS"

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

resource "aws_iam_user_policy_attachment" "EFS_read_write_policy_attachment" {
  user       = aws_iam_user.user-1.name
  policy_arn = aws_iam_policy.EFS_rw_policy.arn
}

resource "aws_instance" "nebo-ec2" { # Bastion host to reach ec2 on private subnet
  ami           = var.ami
  instance_type = var.instance-type
  key_name               = data.aws_key_pair.ec2-key.key_name
  vpc_security_group_ids = [aws_security_group.sg-nebo-efs.id]
  subnet_id = var.public_subnet[0] #Need to associate to subnet created so we can create SG inside the VPC
  associate_public_ip_address = true

  tags = {
    Name = "nebo-efs-host" # Tag needed so IAM bastion user can reach that resource
  }
}

data "aws_key_pair" "ec2-key" {
  key_name = "centos-ec2"
}

resource "aws_security_group" "sg-nebo-efs" {
  name        = "efs-sg"
  description = "Security group for ec2 with efs"
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

