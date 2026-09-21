terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region for the experiment resources."
  default     = "eu-west-2"
}

variable "target_instance_id" {
  type        = string
  description = "Existing sandbox EC2 instance to target."
}

provider "aws" {
  region = var.aws_region
}

# This module intentionally does not execute a destructive action by itself.
# Use the target_instance_id with your approved AWS FIS/SSM experiment workflow.
output "target_instance_id" {
  value = var.target_instance_id
}
