variable "aws_profile" {
  type    = string
  default = "packer-profile"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami_owner" {
  type    = string
  default = "249440625046"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_username" {
  type    = string
  default = "admin"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "webapp" {
  profile       =   var.aws_profile
  ami_name      = "webapp-ami-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region
  source_ami    = "ami-06db4d78cb1d3bbf9"
  ssh_username  = var.ssh_username
  ami_users     = ["057915486037", "822421370804"]
  ssh_agent_auth = false
}

build {
  sources = ["source.amazon-ebs.webapp"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /tmp/webapp && sudo chown admin:admin /tmp/webapp"
    ]
  }

  provisioner "shell" {
    inline = [
      "ls -ld /tmp/webapp",
      "id"
    ]
  }

  provisioner "file" {
    source      = "./"
    destination = "/tmp/webapp"
    direction   = "upload"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/webapp",
      "sudo mv /tmp/webapp/* /opt/webapp/",
      "sudo chown -R nobody:nogroup /opt/webapp"
    ]
  }

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update",
      "sudo apt-get install -y mariadb-server mariadb-client"
    ]
  }

  provisioner "shell" {
    script = "./script.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo apt clean",
      "sudo rm -rf /var/lib/apt/lists/*"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
