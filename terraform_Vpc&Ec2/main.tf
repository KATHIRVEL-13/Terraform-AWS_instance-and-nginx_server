terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
# VPC
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-vpc"
  }
}
# subnet-1
resource "aws_subnet" "pub-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "my-vpc-pub-subnet"
  }
}
# subnet-2
resource "aws_subnet" "pri-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "my-vpc-pri-subnet"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-igw"
  }
}
# route table
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    Name = "my-pub-route-table"
  }
}
# route table association
resource "aws_route_table_association" "pub-ass-1" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.pub-rt.id
  depends_on = [aws_internet_gateway.myigw]
}
#eip
resource "aws_eip" "myeip" {
  domain   = "vpc"
}
# nat gateway
resource "aws_nat_gateway" "tnat" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pub-subnet.id

  tags = {
    Name = "My=vpc-NAT"
  }
}

# private route table
resource "aws_route_table" "pri-rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tnat.id
  }
  tags = {
    Name = "my-pri-route-table"
  }
}

resource "aws_route_table_association" "pub-ass-2" {
  subnet_id      = aws_subnet.pri-subnet.id
  route_table_id = aws_route_table.pri-rt.id
  #depends_on = [aws_internet_gateway.myigw]
}
#security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "my-sg-1" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "my-sg-2" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "my-sg" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
#ec2 instance public
resource "aws_instance" "myec2-1" {
  ami           = "ami-00a929b66ed6e0de6" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pub-subnet.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name = "shell_scripting"
  associate_public_ip_address = true

  tags = {
    Name = "my-ec2-instance-pub-1"
  }
}
#ec2 instance public
resource "aws_instance" "myec2-2" {
  ami           = "ami-00a929b66ed6e0de6" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pri-subnet.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name = "shell_scripting"
  

  tags = {
    Name = "my-ec2-instance-pri-1"
  }
}
