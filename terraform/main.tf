terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.37.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.app_name}-vpc-main"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "${var.app_name}-subnet-public"
  }
}
resource "aws_security_group" "app_sg" {
  name = "${var.app_name}-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.app_name}-sg"
  }
}
resource "aws_s3_bucket" "app_storage" {
  bucket = "${var.app_name}-storage"
  tags = {
    Name = "${var.app_name}-storage"
  }
}
resource "aws_s3_bucket_acl" "app_storage_acl" {
  bucket = aws_s3_bucket.app_storage.id
  acl = "public-read"
}
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_ecr_repository" "app_repo" {
  name = var.app_name
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "${var.app_name}-repo"
  }
  image_scanning_configuration {
    scan_on_push = false
  }
}
resource "aws_db_instance" "app_db_instance" {
  identifier = "${var.app_name}-db"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_name           = "restaurant"
  username          = "admin"
  password = "SuperSecret123"
  skip_final_snapshot = true
  publicly_accessible = true
  storage_encrypted = false
  tags = {
      Name = "${var.app_name}-db"
  }
}