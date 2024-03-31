provider "aws" {
    region = "eu-central-1"
   profile = "fahaddevaws2"
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

}






resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress  {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress  {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []

    }

     tags  = {
    Name = "${var.env_prefix}-sg"
 }
}

data "aws_ami"  "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["al2023-ami-*-kernel-6.1-x86_64"]
      
    }

    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
}



resource "aws_instance" "mypp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    subnet_id = module.myapp-subnet.subnet.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    # user_data = file("entry-script.sh")
    tags = {
         Name = "${var.env_prefix}-server"
    }

    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key =  file(var.private_key_location)
    }

    # provisioner "remote-exec" {
    #     inline = [
    #         "export ENV=dev",
    #         "mkdir newdir"
    #     ]
      
    # }

    provisioner "file" {
         source = "entry_script.sh"
         destination = "/home/ec2-user/entry_script-on-ec2.sh"
      
    }

    provisioner "remote-exec" {
        script = file("entry_script-on-ec2.sh")
    }
 


}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
  
}




# resource "aws_route_table_association" "main-rtb-subnet" {
#     subnet_id = aws_subnet.myapp-subnet-1.id
#     route_table_id = aws_default_route_table.main-rtb.id
# }


  
# resource "aws_route_table_association" "a-rtb-subnet" {
#  subnet_id = aws_subnet.myapp-subnet-1.id
# route_table_id = aws_route_table.myapp-route-table.id
# }









