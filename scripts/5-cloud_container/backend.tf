terraform {
  backend "s3" {
    bucket = "tf-state-david"
    key = "peex-container/terraform.tfstate"
    region = "us-east-1" 
  }
}