provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source          = "../../modules/vpc"
  vpc_name        = "gcc-vpc-dev"
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  environment     = var.environment
  kms_key_arn     = module.security.kms_key_arn
}

module "security" {
  source      = "../../modules/security"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "compute" {
  source             = "../../modules/compute"
  environment        = var.environment
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.security.web_sg_id]
  kms_key_arn        = module.security.kms_key_arn
  s3_bucket_arn      = module.s3.bucket_arn
}

module "s3" {
  source      = "../../modules/s3"
  environment = var.environment
  kms_key_arn = module.security.kms_key_arn
}

module "monitoring" {
  source               = "../../modules/monitoring"
  environment          = var.environment
  flow_log_group_name  = module.vpc.flow_log_group_name
}

module "ecr" {
  source      = "../../modules/ecr"
  environment = var.environment
  kms_key_arn = module.security.kms_key_arn
}

module "alb" {
  source            = "../../modules/alb"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
}

module "ecs" {
  source             = "../../modules/ecs"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  kms_key_arn        = module.security.kms_key_arn
  private_subnet_ids = module.vpc.private_subnets 
  security_group_ids = [module.alb.alb_security_group_id]
  target_group_arn   = module.alb.alb_target_group_arn
  container_image = "725770766740.dkr.ecr.ap-southeast-1.amazonaws.com/dev-app-repo:latest"
}