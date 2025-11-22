terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

#######################
#-Infrastructure Setup
#######################

#--------------------------------
#-Node 1: Frontend/Tier 1 (NGINX)
#--------------------------------
resource "aws_instance" "frontend_nginx" {
  ami                    = "ami-01571f0f73a40c9d8"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-0786335ea9e3bbe1d"
  vpc_security_group_ids = ["sg-01ce2395a89767248"]
  key_name               = "MasterClass9"

  tags = {
    Name = "Node-1-Frontend-NGINX"
    Tier = "Tier-1"
  }
}

#------------------------------------------------------
#-Node 2: Backend/Tier 2 (Python 3) - runs on port 8080
#------------------------------------------------------
resource "aws_instance" "backend_python" {
  ami                    = "ami-00b25677cf6aa5ec1"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-0786335ea9e3bbe1d"
  vpc_security_group_ids = ["sg-01ce2395a89767248"]
  key_name               = "MasterClass9"

  tags = {
    Name = "Node-2-Backend-Python-8080"
    Tier = "Tier-2"
    Port = "8080"
  }
}

#-----------------------------------------------------
#-Node 3: Backend/Tier 2 (Java 17) - runs on port 9090
#-----------------------------------------------------
resource "aws_instance" "backend_java" {
  ami                    = "ami-00b25677cf6aa5ec1"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-0786335ea9e3bbe1d"
  vpc_security_group_ids = ["sg-01ce2395a89767248"]
  key_name               = "MasterClass9"

  tags = {
    Name = "Node-3-Backend-Java-9090"
    Tier = "Tier-2"
    Port = "9090"
  }
}