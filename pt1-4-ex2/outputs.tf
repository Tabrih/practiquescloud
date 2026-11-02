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
