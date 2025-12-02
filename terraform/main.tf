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
  vpc_id      = "vpc-0554333af64d61d92"

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

########################
#-EC2 Instances
########################


#--------------------------------
#-Node 1: Frontend/Tier 1 (NGINX)
#--------------------------------
resource "aws_instance" "web_node" {
  ami                    = "ami-054f42f3b4c78e8aa"
  instance_type          = "t2.medium"
  subnet_id              = "subnet-03e8a88d085ee2c50"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "jenkinskp"

  tags = {
    Name = "web_node"
  }
}

#------------------------------------------------------
#-Node 2: Backend/Tier 2 (Python 3) - runs on port 8080
#------------------------------------------------------
resource "aws_instance" "backend_python" {
  ami                    = "ami-05d520d4ac0d6e443"
  instance_type          = "t2.medium"
  subnet_id              = "subnet-03e8a88d085ee2c50"
  vpc_security_group_ids = ["vpc-0554333af64d61d92"]
  key_name               = "jenkinskp"

  tags = {
    Name = "Node-2-Backend-Python-8080"
  }
}

#-----------------------------------------------------
#-Node 3: Backend/Tier 2 (Java 17) - runs on port 9090
#-----------------------------------------------------
resource "aws_instance" "backend_java" {
  ami                    = "ami-05d520d4ac0d6e443"
  instance_type          = "t2.medium"
  subnet_id              = "subnet-03e8a88d085ee2c50"
  vpc_security_group_ids = ["vpc-0554333af64d61d92"]
  key_name               = "jenkinskp"

  tags = {
    Name = "Node-3-Backend-Java-9090"
  }
}
