provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Project = "state-machine-frenzy"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "luk-iac-nc"
    key    = "state-machine-frenzy"
    region = "eu-central-1"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
