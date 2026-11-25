# Example production topology: AWS + EKS + managed PostgreSQL (Aurora-shaped).
# PROVIDER ASSUMPTIONS: AWS provider ~> 5.x, region configured via variable.
# This module is declarative only and MUST NOT be applied without explicit authorization.
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

variable "region" { type = string, default = "us-east-1" }
variable "cluster_name" { type = string, default = "kd-prod" }

provider "aws" { region = var.region }

# VPC and subnets are intentionally omitted here; production must supply a VPC with
# private subnets, NAT, flow logs and KMS before applying (documented in docs/deployment.md).

resource "aws_eks_cluster" "kd" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  version  = "1.30"
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }
}

variable "private_subnet_ids" { type = list(string) }

resource "aws_iam_role" "eks" {
  name = "${var.cluster_name}-eks"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "sts:AssumeRole",
      Principal = { Service = "eks.amazonaws.com" } }]
  })
}

resource "aws_db_instance" "global" {
  identifier          = "${var.cluster_name}-global"
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.r6g.xlarge"
  allocated_storage   = 100
  storage_encrypted   = true
  multi_az            = true
  username            = "kd"
  password            = var.db_password
  db_name             = "kd_global"
  skip_final_snapshot = false
  backup_retention_period = 14
}

variable "db_password" { type = string, sensitive = true }

# Realm shards are provisioned by repeating this module per shard; capacity is added
# by new shards/DB instances, not by replicas of the same writable state.
resource "aws_db_instance" "realm" {
  for_each            = toset(["a", "b"])
  identifier          = "${var.cluster_name}-realm-${each.key}"
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.r6g.2xlarge"
  allocated_storage   = 500
  storage_encrypted   = true
  multi_az            = true
  username            = "kd"
  password            = var.db_password
  db_name             = "kd_realm_${each.key}"
  backup_retention_period = 30
}

output "eks_cluster" { value = aws_eks_cluster.kd.name }
output "global_db" { value = aws_db_instance.global.address }
output "realm_dbs" { value = { for k, v in aws_db_instance.realm : k => v.address } }
