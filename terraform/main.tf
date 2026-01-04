terraform {
  backend "s3" {
    bucket  = "olawale-s3-devops-bucket"
    key     = "envs/dev/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Web Instances (Frontend with Nginx)
resource "aws_instance" "web" {
  count                       = 2
  ami                         = var.web_ami
  instance_type               = var.instance_type
  subnet_id                   = count.index == 0 ? aws_subnet.public_subnet_1.id : aws_subnet.public_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "web-instance-${count.index + 1}"
  }
}

# Backend Instances (FastAPI) - KEPT IN PRIVATE SUBNET
# Note: These will still have timeout errors if they try to run yum/dnf update
# until you add a NAT Gateway later.
resource "aws_instance" "backend" {
  count                  = 2
  ami                    = var.backend_ami
  instance_type          = var.instance_type
  subnet_id              = count.index == 0 ? aws_subnet.private_subnet_1.id : aws_subnet.private_subnet_2.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.key_name
  associate_public_ip_address = false 

  tags = {
    Name = "backend-instance-${count.index + 1}"
  }
}

# Web Security Group
resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.project_network.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-sg" }
}

# Jenkins Security Group
resource "aws_security_group" "jenkins_sg" {
  name   = "jenkins-sg"
  vpc_id = aws_vpc.project_network.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jenkins-sg" }
}

# Jenkins EC2 instance - MOVED TO PUBLIC SUBNET
resource "aws_instance" "project_tool_server" {
  count                       = 1
  ami                         = var.backend_ami
  instance_type               = var.instance_type
  # UPDATED: Now using Public Subnet 1
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  key_name                    = var.key_name
  # UPDATED: Assigned Public IP so it can reach Amazon Linux repos
  associate_public_ip_address = true

  tags = {
    Name = "project_tool_server"
  }
}

# Backend Security Group
resource "aws_security_group" "backend_sg" {
  name   = "backend-sg"
  vpc_id = aws_vpc.project_network.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "backend-sg" }
}