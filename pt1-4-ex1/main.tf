###############################################################################
# pràctiques cloud - pt1-4-ex1
# Exercici 1: primeres instàncies EC2 amb Terraform
#
# Crea 2 instàncies EC2 t3.micro amb Amazon Linux 2023 a la regió us-east-1,
# dins de la VPC per defecte del compte.
###############################################################################

terraform {
  required_version = ">= 1.5.0"

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

###############################################################################
# Variables
###############################################################################

variable "aws_region" {
  description = "Regió AWS on es despleguen els recursos"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipus d'instància EC2"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Nombre d'instàncies a crear"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Key pair per accedir per SSH. A AWS Academy Learner Lab el key pair predefinit és 'vockey'"
  type        = string
  default     = "vockey"
}

variable "project_tag" {
  description = "Etiqueta comuna per identificar els recursos de la pràctica"
  type        = string
  default     = "pt1-4-ex1"
}

###############################################################################
# AMI d'Amazon Linux 2023
#
# En lloc de fixar un ID d'AMI (que canvia segons la regió i el temps), es
# consulta la imatge més recent publicada per Amazon que compleixi els filtres.
###############################################################################

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

###############################################################################
# Xarxa
#
# S'utilitza la VPC per defecte del compte (la que porta subxarxes públiques i
# Internet Gateway). Així l'exercici se centra en les instàncies EC2.
###############################################################################

data "aws_vpc" "default" {
  default = true
}

###############################################################################
# Instàncies EC2
###############################################################################

resource "aws_instance" "web" {
  count = var.instance_count

  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name    = "${var.project_tag}-web-${count.index + 1}"
    Project = var.project_tag
  }
}

###############################################################################
# Outputs
###############################################################################

output "instance_ids" {
  description = "IDs de les instàncies creades"
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "IPs públiques de les instàncies"
  value       = aws_instance.web[*].public_ip
}

output "ami_id" {
  description = "AMI d'Amazon Linux 2023 utilitzada"
  value       = data.aws_ami.al2023.id
}
