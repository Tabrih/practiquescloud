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
