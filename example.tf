terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "remote" {
    organization = "ofr-study"

    workspaces {
      name = "aws-terraform-cloud1"
    }
  }
}

provider "random" {
  version = "2.2"
}

# Application server
provider "aws" {
  version = "~> 3.0"
  region  = var.aws_region
}

resource "aws_instance" "example" {
  ami           = "ami-04edc9c2bfcf9a772"
  instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example.id
}

output "ip" {
  description = "The public IP of the application server."
  value = aws_eip.ip.public_ip
}

# Database service (DynamoDB)
resource "random_pet" "table_name" {}

resource "aws_dynamodb_table" "tfc_example_table" {
  name = "${var.db_table_name}-${random_pet.table_name.id}"

  read_capacity  = var.db_read_capacity
  write_capacity = var.db_write_capacity
  hash_key       = "UUID"

  attribute {
    name = "UUID"
    type = "S"
  }
}

output "tfc_example_table_arn" {
  value = aws_dynamodb_table.tfc_example_table.arn
}