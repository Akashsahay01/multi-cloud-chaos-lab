terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "target_asg_name" {
  type = string
}

provider "aws" {
  region = var.aws_region
}

output "target_asg_name" {
  value = var.target_asg_name
}
