terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  profile     = "default"
  region      = var.region
}

#----------------------------
# Configure modules
#----------------------------
module "aws_lambda_function" {
  source       = "./modules/lambda"
  project      = var.project
  env          = var.env
  s3_bucket    = module.aws_s3.source_s3_bucket
}

module "aws_s3" {
  source       = "./modules/s3"
  project      = var.project
  env          = var.env
}
