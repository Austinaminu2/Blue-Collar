terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }

  backend "s3" {
    bucket         = "bluecollar-terraform-state"
    key            = "bluecollar/staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "bluecollar-terraform-locks"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = { Project = "BlueCollar", Environment = "staging", ManagedBy = "Terraform" }
  }
}

module "networking" {
  source      = "../../modules/networking"
  environment = "staging"
  vpc_cidr    = "10.1.0.0/16"
}

module "database" {
  source             = "../../modules/database"
  environment        = "staging"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  db_instance_class  = "db.t3.micro"   # smaller than prod
  db_name            = "bluecollar_staging"
  db_username        = var.db_username
  db_password        = var.db_password
}

module "registry" {
  source      = "../../modules/registry"
  environment = "staging"
}

variable "db_username" { type = string; sensitive = true }
variable "db_password" { type = string; sensitive = true }

output "db_endpoint"    { value = module.database.endpoint; sensitive = true }
output "ecr_repo_url"   { value = module.registry.repository_url }
