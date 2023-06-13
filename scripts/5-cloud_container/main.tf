resource "aws_ecr_repository" "ecr-repo" {
  name = "peex-ecr-repo"
  image_tag_mutability = "MUTABLE"
}