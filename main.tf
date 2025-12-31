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

# Web Instances (Frontend with Nginx)
resource "aws_instance" "web" {
    count                = 2
    ami                  = var.web_ami
    instance_type        = var.instance_type
    subnet_id            = aws_subnet.public[count.index].id
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    associate_public_ip_address = true

    tags = {
        Name = "web-instance-${count.index + 1}"
    }
}

# Backend Instances (FastAPI)
resource "aws_instance" "backend" {
    count                = 2
    ami                  = var.backend_ami
    instance_type        = var.instance_type
    subnet_id            = aws_subnet.private[count.index].id
    vpc_security_group_ids = [aws_security_group.backend_sg.id]

    tags = {
        Name = "backend-instance-${count.index + 1}"
    }
}

# Web Security Group
resource "aws_security_group" "web_sg" {
    name        = "web-sg"
    vpc_id      = var.vpc_id

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

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "web-sg"
    }
}

# Backend Security Group
resource "aws_security_group" "backend_sg" {
    name        = "backend-sg"
    vpc_id      = var.vpc_id

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

    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "backend-sg"
    }
}