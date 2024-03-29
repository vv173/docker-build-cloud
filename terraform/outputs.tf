output "eip" {
  value = aws_eip.docker_eip.public_ip
  description = "The Elastic IP address (EIP) associated with the EC2 instance."
}
