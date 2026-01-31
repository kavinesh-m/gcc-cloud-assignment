resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.environment}-app-repo"
  image_tag_mutability = "IMMUTABLE" # Prevents image overwriting (Security Best Practice)

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn # Uses your GCC main key
  }

  image_scanning_configuration {
    scan_on_push = true # Mandatory for GCC to find vulnerabilities
  }
}

# Lifecycle policy to keep the repo clean and reduce costs
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}