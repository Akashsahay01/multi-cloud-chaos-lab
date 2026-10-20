#!/usr/bin/env bash
set -Eeuo pipefail

region="${AWS_REGION:-eu-west-2}"
environment="${1:-staging}"

if [[ "$environment" != "staging" && "$environment" != "production" ]]; then
  echo "Usage: $0 [staging|production]" >&2
  exit 2
fi

echo "Checking authenticated AWS identity..."
aws sts get-caller-identity --output table

echo "Finding instances for project environment: $environment"
aws ec2 describe-instances \
  --region "$region" \
  --filters "Name=tag:Project,Values=DOE-M5-Project2" "Name=tag:Environment,Values=$environment" \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,ImageId,PrivateIpAddress,PublicIpAddress]' \
  --output table

echo "AWS inspection completed."
