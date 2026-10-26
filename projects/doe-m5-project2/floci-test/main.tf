
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://localhost:4566"
  }
}

resource "aws_instance" "floci_test" {
  ami           = "ami-amazonlinux2023-arm64"
  instance_type = "t4g.micro"
  user_data = "app_version=1.0.0"

  lifecycle {
  create_before_destroy = true
}

  tags = {
    Name        = "doe-m5-floci-test"
    Project     = "DOE-M5-Project2"
    Environment = "local"
    AppVersion  = "1.0.0"
  }
}


output "instance_id" {
  value = aws_instance.floci_test.id
  
}

