###############################################################################
# pràctiques cloud - pt1-4-ex2
# Part C: Desplegament amb Terraform
#
# VPC personalitzada 10.0.0.0/16 amb 3 subxarxes públiques a us-east-1a
# i 2 instàncies EC2 t3.micro (Amazon Linux 2023) per subxarxa = 6 instàncies.
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

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instances_per_subnet" {
  type    = number
  default = 2
}

variable "key_name" {
  type    = string
  default = "vockey"
}

variable "ssh_cidr" {
  type    = string
  default = "81.42.248.211/32"
}

variable "project_tag" {
  type    = string
  default = "pt1-4-ex2"
}

locals {
  subnets = {
    a = { cidr_block = "10.0.32.0/25", label = "A" }
    b = { cidr_block = "10.0.30.0/23", label = "B" }
    c = { cidr_block = "10.0.33.0/28", label = "C" }
  }

  instances = merge([
    for key, subnet in local.subnets : {
      for n in range(1, var.instances_per_subnet + 1) :
      "${key}${n}" => { subnet_key = key, number = n }
    }
  ]...)
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
    Name    = "${var.project_tag}-vpc"
    Project = var.project_tag
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_tag}-igw", Project = var.project_tag }
}

resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_tag}-subnet-${each.key}"
    Label   = each.value.label
    CIDR    = each.value.cidr_block
    Project = var.project_tag
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "${var.project_tag}-rt-public", Project = var.project_tag }
}

resource "aws_route_table_association" "this" {
  for_each = local.subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name        = "${var.project_tag}-sg"
  description = "HTTP public i SSH restringit"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_tag}-sg", Project = var.project_tag }
}

resource "aws_instance" "web" {
  for_each = local.instances

  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.this[each.value.subnet_key].id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y httpd
    echo "<h1>${var.project_tag} - ${var.project_tag}-${each.value.subnet_key}-web-${each.value.number}</h1>" > /var/www/html/index.html
    systemctl enable --now httpd
  EOF

  tags = {
    Name    = "${var.project_tag}-${each.value.subnet_key}-web-${each.value.number}"
    Subnet  = "${var.project_tag}-subnet-${each.value.subnet_key}"
    Project = var.project_tag
  }
}

output "vpc_id" { value = aws_vpc.main.id }
output "subnet_ids" { value = { for k, s in aws_subnet.this : k => s.id } }
output "subnet_cidrs" { value = { for k, s in aws_subnet.this : k => s.cidr_block } }
output "instances" {
  value = {
    for k, i in aws_instance.web : k => {
      name       = i.tags["Name"]
      subnet     = i.tags["Subnet"]
      private_ip = i.private_ip
      public_ip  = i.public_ip
      url        = "http://${i.public_ip}"
    }
  }
}
output "urls" { value = [for i in aws_instance.web : "http://${i.public_ip}"] }
output "ssh_commands" { value = [for i in aws_instance.web : "ssh -i ~/.ssh/vockey.pem ec2-user@${i.public_ip}"] }
