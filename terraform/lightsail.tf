variable "basename" {
  type = string
  nullable = false
}

variable "db_pass" {
    type = string
    nullable = false
}

variable "aws_region" {
    type = string
    nullable = false
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    awslightsail = {
      source = "deyoungtech/awslightsail"
    }
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

provider "awslightsail" {
  region = "${var.aws_region}"
}

resource "awslightsail_container_service" "lightsail-container-staging" {
  name        = "${var.basename}-staging"
  power       = "micro"
  scale       = 1
  is_disabled = false
}

resource "awslightsail_container_service" "lightsail-container-production" {
  name        = "${var.basename}-production"
  power       = "small"
  scale       = 1
  is_disabled = false
}

resource "awslightsail_database" "lightsail-database" {
  name                 = "${var.basename}-db"
  availability_zone    = "${var.aws_region}a"
  master_database_name = "${var.basename}_master"
  master_password      = "${var.db_pass}"
  master_username      = "${var.basename}_root"
  blueprint_id         = "mysql_8_0"
  bundle_id            = "small_1_0"
  publicly_accessible  = true
}
