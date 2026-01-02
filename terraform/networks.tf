
# VPC
resource "aws_vpc" "project_network" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = "Project_network"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "project_igw" {
    vpc_id = aws_vpc.project_network.id

    tags = {
        Name = "project_igw"
    }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
    vpc_id            = aws_vpc.project_network.id
    cidr_block        = var.public_subnet_1_cidr
    availability_zone = "${var.aws_region}a"

    tags = {
        Name = "public_project_subnet_1"
        Tier = "Web App Tier"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id            = aws_vpc.project_network.id
    cidr_block        = var.public_subnet_2_cidr
    availability_zone = "${var.aws_region}b"

    tags = {
        Name = "public_project_subnet_2"
        Tier = "Web App Tier"
    }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
    vpc_id            = aws_vpc.project_network.id
    cidr_block        = var.private_subnet_1_cidr
    availability_zone = "${var.aws_region}a"

    tags = {
        Name = "private_project_subnet_1"
        Tier = "Application Tier"
    }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id            = aws_vpc.project_network.id
    cidr_block        = var.private_subnet_2_cidr
    availability_zone = "${var.aws_region}b"

    tags = {
        Name = "private_project_subnet_2"
        Tier = "DB Tier"
    }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.project_network.id

    route {
        cidr_block      = "0.0.0.0/0"
        gateway_id      = aws_internet_gateway.project_igw.id
    }

    tags = {
        Name = "public_rt"
    }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_1_assoc" {
    subnet_id      = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
    subnet_id      = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.project_network.id

    tags = {
        Name = "private_rt"
    }
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_subnet_1_assoc" {
    subnet_id      = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_2_assoc" {
    subnet_id      = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private_rt.id
}