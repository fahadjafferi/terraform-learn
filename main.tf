provider "aws" {
    region = "eu-central-1"
   profile = "fahaddevaws2"
}

variable "subnet_cidr_block" {
    description = "subnet cidr block"  
    default = "10.0.10.0/24"
    type = string
  
}

variable "vpc_cidr_block" {
    description = "vpc cidr block"
}

variable "environment" {
    description = "deployment environment"
  
}

resource "aws_vpc" "development-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = var.environment,
        vpc_env = "dev"
    }
}

resource "aws_subnet" "dev-sub-net-1" {
 vpc_id = aws_vpc.development-vpc.id
 cidr_block = var.subnet_cidr_block
 availability_zone = "eu-central-1a"
 tags = {
        Name = "learning-terraform-course-subnet",
        subnet_env = "dev"
    }
}










