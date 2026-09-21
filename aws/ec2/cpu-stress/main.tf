terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

variable "aws_region" {
  type        = string
  description = "AWS region used by the FIS experiment."
  default     = "eu-west-2"
}

variable "target_tag_key" {
  type        = string
  description = "Tag key used to select the sandbox EC2 target."
  default     = "ChaosLab"
}

variable "target_tag_value" {
  type        = string
  description = "Tag value used to select the sandbox EC2 target."
  default     = "cpu-stress"
}

variable "duration_seconds" {
  type        = number
  description = "CPU stress duration in seconds."
  default     = 60
  validation {
    condition     = var.duration_seconds >= 60 && var.duration_seconds <= 600
    error_message = "duration_seconds must be between 60 and 600 seconds."
  }
}

variable "load_percent" {
  type        = number
  description = "CPU load percentage."
  default     = 50
  validation {
    condition     = var.load_percent >= 1 && var.load_percent <= 100
    error_message = "load_percent must be between 1 and 100."
  }
}

variable "fis_role_name" {
  type        = string
  description = "Name for the IAM role assumed by AWS FIS."
  default     = "multi-cloud-chaos-lab-fis-ssm"
}

resource "aws_iam_role" "fis" {
  name = var.fis_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "fis.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        },
        ArnLike = {
          "aws:SourceArn" = "arn:${data.aws_partition.current.partition}:fis:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:experiment/*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fis_ssm" {
  role       = aws_iam_role.fis.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSFaultInjectionSimulatorSSMAccess"
}

resource "aws_fis_experiment_template" "cpu_stress" {
  description = "Controlled CPU stress against one tagged sandbox EC2 instance."
  role_arn    = aws_iam_role.fis.arn
  stop_condition {
    source = "none"
  }
  action {
    name      = "cpu-stress"
    action_id = "aws:ssm:send-command"
    parameter {
      key   = "documentArn"
      value = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.region}::document/AWSFIS-Run-CPU-Stress"
    }
    parameter {
      key = "documentParameters"
      value = jsonencode({
        DurationSeconds     = tostring(var.duration_seconds)
        LoadPercent         = tostring(var.load_percent)
        InstallDependencies = "True"
      })
    }
    parameter {
      key   = "duration"
      value = "PT10M"
    }
    target {
      key   = "Instances"
      value = "ec2-target"
    }
  }
  target {
    name           = "ec2-target"
    resource_type  = "aws:ec2:instance"
    selection_mode = "COUNT(1)"
    resource_tag {
      key   = var.target_tag_key
      value = var.target_tag_value
    }
  }
  tags = {
    Project     = "multi-cloud-chaos-lab"
    Experiment  = "cpu-stress"
    Environment = "sandbox"
  }
}

output "experiment_template_id" {
  value = aws_fis_experiment_template.cpu_stress.id
}

output "target_tag" {
  value = "${var.target_tag_key}=${var.target_tag_value}"
}
