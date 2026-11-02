provider "aws" {
  region = var.aws_region
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
