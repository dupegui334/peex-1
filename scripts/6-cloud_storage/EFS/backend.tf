terraform {
  backend "s3" {
    bucket = "tf-state-david"
    key    = "peex-storage-efs/terraform.tfstate"
    region = "us-east-1"
  }
}