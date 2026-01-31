terraform {
  backend "s3" {
    bucket         = "aws-cloud-tf-assignment-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}