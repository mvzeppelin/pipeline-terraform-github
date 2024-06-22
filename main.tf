terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.107.0"
    }

  }

  backend "s3" {
    bucket = "mvzeppelin-tf-state-bucket"
    key    = "pipeline-gitlab/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}

}
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "mvzeppelin-tf-state-bucket"
    key    = "aws-vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vnet" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "mvzeppelinsaremotestate"
    container_name       = "terraform-container-state"
    key                  = "azure-vnet/terraform.tfstate"
  }
}
