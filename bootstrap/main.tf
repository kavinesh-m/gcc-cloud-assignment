provider "aws" {
  region = "ap-southeast-1" 
}

# S3 Bucket for State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "aws-cloud-tf-assignment-state-bucket" 
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled" 
  }
}

# DynamoDB Table for Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}