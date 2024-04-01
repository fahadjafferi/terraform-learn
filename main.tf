terraform {
required_version = ">= 0.12"
backend "s3" {
    bucket = "tf-backend"
    key = "myapp/state.tfstate"
    region = "eu-central-1"
}

}

provider "aws" {
    region = "eu-central-1"
   profile = "fahaddevaws2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = var.avail_zone
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = { Name = "${var.env_prefix}-subnet-1"}


  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}



module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = module.vpc.vpc_id
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key_location = var.public_key_location
    subnet_id = module.vpc.public_subnets[0]
    avail_zone = var.avail_zone
    instance_type = var.instance_type
}







# resource "aws_route_table_association" "main-rtb-subnet" {
#     subnet_id = aws_subnet.myapp-subnet-1.id
#     route_table_id = aws_default_route_table.main-rtb.id
# }


  
# resource "aws_route_table_association" "a-rtb-subnet" {
#  subnet_id = aws_subnet.myapp-subnet-1.id
# route_table_id = aws_route_table.myapp-route-table.id
# }









