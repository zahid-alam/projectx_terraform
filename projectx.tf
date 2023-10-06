# Initialize your Terraform project
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

# Define the AWS provider and region
provider "aws" {
  region = "ap-south-1"  
}

# Create a VPC
resource "aws_vpc" "projectx_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "projectx-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.projectx_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.projectx_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "private-subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "projectx_igw" {
  vpc_id = aws_vpc.projectx_vpc.id
}


resource "aws_internet_gateway_attachment" "projectx_igw_attachment" {
  internet_gateway_id = aws_internet_gateway.projectx_igw.id
  vpc_id              = aws_vpc.projectx_vpc.id
}

# Create a default route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.projectx_vpc.id
}

# Create a route for the public subnet to the internet via the internet gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.projectx_igw.id
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Output the VPC ID and Subnet IDs
output "vpc_id" {
  value = aws_vpc.projectx_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}
