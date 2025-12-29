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
  region = "us-east-2"
}

#########################
#-Web Node Security Group
#########################

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow SSH and Port 80 inbound, all outbound"
  vpc_id      = var.project_vpc

  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 80 (web)
  ingress {
    description = "Web port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_security_group"
  }

}

#####################################################
#-Web EC2 Instances (Node 1: Frontend/Tier 1 (NGINX))
#####################################################
resource "aws_instance" "web_node" {
  ami                    = var.frontend_ami
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.project_keyname

  tags = {
    Name = "web_node"
  }
}

#-------------------------------------------------------------
#-Node 2: Backend/Tier 2 (Python 3) Security Group (port 8080)
#-------------------------------------------------------------
resource "aws_security_group" "python_sg" {
  name        = "python_sg"
  description = "Allow SSH and Port 8080 inbound, all outbound"
  vpc_id      = var.project_vpc

  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 8080 (app)
  ingress {
    description = "Pyhton App port 9000"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "python_app_security_group"
  }

}

#########################################
#-Python EC2 Instances
#########################################

resource "aws_instance" "python_node" {
  ami                    = var.backend_ami
  instance_type          = var.project_instance_type
  subnet_id              = "subnet-03e8a88d085ee2c50"
  vpc_security_group_ids = [aws_security_group.python_sg.id]
  key_name               = var.project_keyname

  tags = {
    Name = "python_node"
  }
}



#-------------------------------------------------------------
#-Node 3: Backend/Tier 3 (Java 17) Security Group (port 8080)
#-------------------------------------------------------------
resource "aws_security_group" "java_sg" {
  name        = "java_sg"
  description = "Allow SSH and Port 9090 inbound, all outbound"
  vpc_id      = var.project_vpc

  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 8080 (app)
  ingress {
    description = "Pyhton App port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "java_app_security_group"
  }

}

#########################################
#-Java EC2 Instances
#########################################

resource "aws_instance" "java_node" {
  ami                    = var.backend_ami
  instance_type          = var.project_instance_type
  subnet_id              = "subnet-03e8a88d085ee2c50"
  vpc_security_group_ids = [aws_security_group.java_sg.id]
  key_name               = var.project_keyname

  tags = {
    Name = "java_node"
  }
}

#------------------------------
#Outputs- Public (external) IPs
#------------------------------
output "web_node_ip" {
  description = "Public IP"
  value = aws_instance.web_node.public_ip
}

output "python_node_ip" {
  description = "Public IP"
  value = aws_instance.python_node.public_ip
}

output "java_node_ip" {
  description = "Public IP"
  value = aws_instance.java_node.public_ip
}
