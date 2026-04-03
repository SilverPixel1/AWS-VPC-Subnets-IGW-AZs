provider "aws" {
  region = "eu-central-1"
}

############################
# Variablen
############################

variable "project_name" {
  description = "Namensprefix für alle Ressourcen"
  type        = string
  default     = "demo-vpc"
}

variable "my_ip_cidr" {
  description = "Eigene öffentliche IP für SSH-Zugriff, z. B. 203.0.113.10/32"
  type        = string
}

############################
# VPC
############################

resource "aws_vpc" "main" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

############################
# Internet Gateway
############################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

############################
# Subnets
############################

# Public Subnet - eu-central-1a
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.0.0/20"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet-1-public"
    Tier = "public"
    AZ   = "eu-central-1a"
  }
}

# Private Subnet - eu-central-1b
resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.16.0/20"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-subnet-2-private"
    Tier = "private"
    AZ   = "eu-central-1b"
  }
}

# Private Subnet - eu-central-1c
resource "aws_subnet" "private_3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.32.0/20"
  availability_zone       = "eu-central-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-subnet-3-private"
    Tier = "private"
    AZ   = "eu-central-1c"
  }
}

# Private Subnet - eu-central-1c
resource "aws_subnet" "private_4" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.48.0/20"
  availability_zone       = "eu-central-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-subnet-4-private"
    Tier = "private"
    AZ   = "eu-central-1c"
  }
}

############################
# Route Tables
############################

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rt-private"
  }
}

resource "aws_route_table_association" "private_2_assoc" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_3_assoc" {
  subnet_id      = aws_subnet.private_3.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_4_assoc" {
  subnet_id      = aws_subnet.private_4.id
  route_table_id = aws_route_table.private_rt.id
}

############################
# Security Group
############################

resource "aws_security_group" "ec2_ssh" {
  name        = "${var.project_name}-ec2-ssh"
  description = "Erlaubt SSH nur von meiner IP, Outbound offen"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH von meiner IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "Alle ausgehenden Verbindungen"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-ec2-ssh"
  }
}
