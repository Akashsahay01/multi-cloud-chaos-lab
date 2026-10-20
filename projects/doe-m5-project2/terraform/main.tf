terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}
provider "aws" { region = var.aws_region }
data "aws_vpc" "default" { default = true }
data "aws_subnets" "default" { filter { name = "vpc-id", values = [data.aws_vpc.default.id] } }

variable "aws_region" { type = string, default = "eu-west-2" }
variable "environment" {
  type = string
  validation { condition = contains(["staging", "production"], var.environment), error_message = "environment must be staging or production." }
}
variable "ami_id" {
  type = string
  validation { condition = can(regex("^ami-[0-9a-f]+$", var.ami_id)), error_message = "ami_id must be a concrete AMI ID." }
}
variable "app_version" { type = string }
variable "allowed_cidr" {
  type = string
  description = "Restrict HTTP access to your own public IP in /32 CIDR notation."
  validation { condition = can(cidrhost(var.allowed_cidr, 0)), error_message = "allowed_cidr must be a valid CIDR." }
}
variable "instance_type" { type = string, default = "t3.micro" }

resource "aws_security_group" "app" {
  name = "doe-m5-${var.environment}"
  description = "Restricted HTTP access for the assessment demo"
  vpc_id = data.aws_vpc.default.id
  ingress { from_port = 8080, to_port = 8080, protocol = "tcp", cidr_blocks = [var.allowed_cidr] }
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  tags = { Project = "DOE-M5-Project2", Environment = var.environment }
}
resource "aws_instance" "app" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.app.id]
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    set -eu
    mkdir -p /etc/systemd/system/doe-m5-app.service.d
    cat > /etc/systemd/system/doe-m5-app.service.d/environment.conf <<'UNIT'
    [Service]
    Environment=APP_ENVIRONMENT=${var.environment}
    Environment=APP_VERSION=${var.app_version}
    UNIT
    systemctl daemon-reload
    systemctl enable --now doe-m5-app.service
    systemctl restart doe-m5-app.service
  EOF
  lifecycle { create_before_destroy = true }
  tags = { Name = "doe-m5-${var.environment}", Project = "DOE-M5-Project2", Environment = var.environment, AppVersion = var.app_version }
}
output "instance_id" { value = aws_instance.app.id }
output "public_ip" { value = aws_instance.app.public_ip }
output "health_url" { value = "http://${aws_instance.app.public_ip}:8080/health" }
