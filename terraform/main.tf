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

# --- 1. WEB INSTANCES (Public) ---
resource "aws_instance" "web" {
  count                       = 2
  ami                         = var.web_ami
  instance_type               = var.instance_type
  subnet_id                   = count.index == 0 ? aws_subnet.public_subnet_1.id : aws_subnet.public_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = { Name = "web-instance-${count.index + 1}" }
}

# --- 2. BACKEND INSTANCES (Private) ---
resource "aws_instance" "backend" {
  count                  = 2
  ami                    = var.backend_ami
  instance_type          = var.instance_type
  subnet_id              = count.index == 0 ? aws_subnet.private_subnet_1.id : aws_subnet.private_subnet_2.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.key_name
  associate_public_ip_address = false

  tags = { Name = "backend-instance-${count.index + 1}" }
}

# --- 3. JENKINS TOOL SERVER (Public) ---
resource "aws_instance" "project_tool_server" {
  count                       = 1
  ami                         = var.backend_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true # Needed for GitHub/Pip downloads

  tags = { Name = "project_tool_server" }
}

# --- 4. SECURITY GROUPS ---

# Web SG
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
}

# Jenkins SG
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
}

# Backend SG
resource "aws_security_group" "backend_sg" {
  name   = "backend-sg"
  vpc_id = aws_vpc.project_network.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Only allow internal SSH
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
}

# Database SG
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow inbound traffic from backend only"
  vpc_id      = aws_vpc.project_network.id

  # THE HANDSHAKE: Allow Port 5432 ONLY from Backend SG
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "project_db" {
  identifier           = "project-database"
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20       # Required: Match your current size (e.g., 20)
  username             = "postgres" # Required: Put your current master username
  password             = "Youngman9!" # Required for the block to be valid
  
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
}