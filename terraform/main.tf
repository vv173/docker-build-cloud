provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "docker_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "docker_vpc"
  }
}

resource "aws_subnet" "docker_subnet" {
  vpc_id     = aws_vpc.docker_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "docker_subnet"
  }
}

resource "aws_internet_gateway" "docker_igw" {
  vpc_id = aws_vpc.docker_vpc.id
  tags = {
    Name = "docker_igw"
  }
}

resource "aws_route_table" "docker_rt" {
  vpc_id = aws_vpc.docker_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.docker_igw.id
  }

  tags = {
    Name = "docker_rt"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id = aws_subnet.docker_subnet.id
  route_table_id = aws_route_table.docker_rt.id
}

resource "aws_security_group" "allow_docker_tls" {
  name        = "allow_docker_tls"
  description = "Allow TLS inbound traffic and outbound traffic"
  vpc_id      = aws_vpc.docker_vpc.id

  tags = {
    Name = "allow_docker_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_port" {
  security_group_id = aws_security_group.allow_docker_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_docker_port" {
  security_group_id = aws_security_group.allow_docker_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 1537
  ip_protocol       = "tcp"
  to_port           = 1537
}

resource "aws_instance" "docker_host" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.docker_subnet.id
  vpc_security_group_ids = [ aws_security_group.allow_docker_tls.id ]

  tags = {
    Name = "docker_host"
  }
}

resource "aws_eip" "docker_eip" {
  instance = aws_instance.docker_host.id
  domain   = "vpc"

  tags = {
    Name = "docker_eip"
  }
}