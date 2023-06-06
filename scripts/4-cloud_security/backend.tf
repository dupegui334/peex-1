terraform {
  backend "s3" {
    bucket = "tf-state-david"
    key = "peex-security/terraform.tfstate"
    region = "us-east-1" 
  }
}