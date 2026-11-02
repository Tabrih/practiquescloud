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

variable "aws_region" {
  description = "Regió AWS on es despleguen els recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_tag" {
  description = "Etiqueta comuna per identificar els recursos de la pràctica"
  type        = string
  default     = "pt1-4-ex2"
}

variable "vpc_name" {
  description = "Nom de la VPC"
  type        = string
  default     = "proyecto-vpc"
}

variable "vpc_cidr" {
  description = "Rang CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "Zona de disponibilitat on es creen les tres subxarxes"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "Tipus d'instància EC2"
  type        = string
  default     = "t3.micro"
}

variable "instances_per_subnet" {
  description = "Nombre d'instàncies a crear a cada subxarxa"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Key pair per accedir per SSH"
  type        = string
  default     = "vockey"
}

variable "subnets" {
  description = "Subxarxes de la VPC, amb el nom i el CIDR de cadascuna"
  type = map(object({
    name = string
    cidr = string
  }))
  default = {
    a = {
      name = "Subnet A"
      cidr = "10.0.32.0/25"
    }
    b = {
      name = "Subnet B"
      cidr = "10.0.30.0/23"
    }
    c = {
      name = "Subnet C"
      cidr = "10.0.33.0/28"
    }
  }
}

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

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = var.vpc_name
    Project = var.project_tag
  }
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = var.availability_zone

  tags = {
    Name    = each.value.name
    Project = var.project_tag
  }
}

locals {
  instances = flatten([
    for subnet_key, subnet in var.subnets : [
      for index in range(var.instances_per_subnet) : {
        key        = "${subnet_key}-${index + 1}"
        subnet_key = subnet_key
        name       = "${subnet.name} Ins${index + 1}"
      }
    ]
  ])
}

resource "aws_instance" "this" {
  for_each = { for instance in local.instances : instance.key => instance }

  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.this[each.value.subnet_key].id

  tags = {
    Name    = each.value.name
    Project = var.project_tag
  }
}

output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR de la VPC"
  value       = aws_vpc.main.cidr_block
}

output "subnets" {
  description = "Subxarxes creades, amb ID, CIDR i zona de disponibilitat"
  value = {
    for key, subnet in aws_subnet.this : subnet.tags.Name => {
      id   = subnet.id
      cidr = subnet.cidr_block
      az   = subnet.availability_zone
    }
  }
}

output "instances" {
  description = "Instàncies EC2 creades, amb ID, subxarxa i IP privada"
  value = {
    for key, instance in aws_instance.this : instance.tags.Name => {
      id         = instance.id
      subnet_id  = instance.subnet_id
      private_ip = instance.private_ip
    }
  }
}

output "instance_count" {
  description = "Nombre total d'instàncies creades"
  value       = length(aws_instance.this)
}

output "ami_id" {
  description = "AMI d'Amazon Linux 2023 utilitzada"
  value       = data.aws_ami.al2023.id
}
