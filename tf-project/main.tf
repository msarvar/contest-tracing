terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = ">= 3.0"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc_grp_1" {
  source = "./modules/vpc"
}

module "vpc_grp_2" {
  source = "./modules/vpc"
}

module "vpc_grp_3" {
  source = "./modules/vpc"
}

module "vpc_grp_4" {
  source = "./modules/vpc"
}
