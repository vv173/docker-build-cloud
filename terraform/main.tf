provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "docker_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

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
  subnet_id      = aws_subnet.docker_subnet.id
  route_table_id = aws_route_table.docker_rt.id
}

resource "aws_security_group" "allow_docker_tls" {
  name        = "allow_docker_tls"
  description = "Allow TLS inbound traffic and outbound traffic"
  vpc_id      = aws_vpc.docker_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

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

resource "aws_key_pair" "docker_key" {
  key_name   = "docker_key"
  public_key = file("~/.ssh/docker_cloud_build_key.pub")
}

resource "aws_instance" "docker_builder" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.docker_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_docker_tls.id]
  key_name               = aws_key_pair.docker_key.key_name

  tags = {
    Name = "docker_builder"
  }
}

resource "aws_eip" "docker_eip" {
  instance = aws_instance.docker_builder.id
  domain   = "vpc"

  tags = {
    Name = "docker_eip"
  }
}

resource "ansible_host" "docker_builder" {
  name   = aws_eip.docker_eip.public_dns
  groups = ["docker_build_instances"]
  variables = {
    ansible_user                 = "ec2-user",
    ansible_host                 = aws_eip.docker_eip.public_ip,
    ansible_ssh_private_key_file = "~/.ssh/docker_cloud_build_key"
  }

  depends_on = [
    aws_instance.docker_builder,
    aws_eip.docker_eip
  ]
}

