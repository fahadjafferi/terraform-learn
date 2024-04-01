output "ec2_public_ip" {
   value = aws_instance.mypp-server.instance.public_ip
  
}