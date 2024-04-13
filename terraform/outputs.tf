output "ec2_id" {
  value       = aws_instance.docker_builder.id
  description = "The ID of a EC2 instance"
}

output "eip" {
  value       = aws_eip.docker_eip.public_ip
  description = "The Elastic IP address (EIP) associated with the EC2 instance."
}

output "dns_name" {
  value       = aws_eip.docker_eip.public_dns
  description = "Public domain name associated with the EC2 instance."
}
