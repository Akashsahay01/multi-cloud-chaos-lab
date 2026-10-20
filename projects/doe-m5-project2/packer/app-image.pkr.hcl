packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" { type = string, default = "eu-west-2" }
variable "instance_type" { type = string, default = "t3.micro" }

source "amazon-ebs" "app" {
  region        = var.aws_region
  instance_type = var.instance_type
  ami_name      = "doe-m5-project2-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  ssh_username  = "ec2-user"
  source_ami_filter {
    filters = { name = "al2023-ami-2023.*-x86_64", root-device-type = "ebs", virtualization-type = "hvm" }
    owners = ["137112412989"]
    most_recent = true
  }
  tags = { Project = "DOE-M5-Project2", ManagedBy = "Packer" }
}

build {
  name = "doe-m5-app-image"
  sources = ["source.amazon-ebs.app"]
  provisioner "shell" {
    inline = ["sudo dnf install -y python3", "sudo install -d -o ec2-user -g ec2-user /opt/doe-m5-app"]
  }
  provisioner "file" { source = "projects/doe-m5-project2/app/app.py", destination = "/tmp/app.py" }
  provisioner "shell" {
    inline = [
      "sudo install -o ec2-user -g ec2-user -m 0644 /tmp/app.py /opt/doe-m5-app/app.py",
      "sudo tee /etc/systemd/system/doe-m5-app.service >/dev/null <<'EOF'\n[Unit]\nDescription=DOE M5 demo app\nAfter=network.target\n[Service]\nUser=ec2-user\nWorkingDirectory=/opt/doe-m5-app\nEnvironment=PORT=8080\nEnvironment=APP_ENVIRONMENT=unset\nEnvironment=APP_VERSION=image-baked\nExecStart=/usr/bin/python3 /opt/doe-m5-app/app.py\nRestart=on-failure\n[Install]\nWantedBy=multi-user.target\nEOF",
      "sudo systemctl enable doe-m5-app.service"
    ]
  }
}
