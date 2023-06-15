terraform {
  backend "s3" {
    bucket = "tf-state-david"
    key    = "peex-storage/terraform.tfstate"
    region = "us-east-1"
  }
}