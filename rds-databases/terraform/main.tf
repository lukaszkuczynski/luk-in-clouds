provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Project = "dbs-c01-testing"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "luk-iac-nc"
    key    = "dbs-c01-testing"
    region = "eu-central-1"
  }
}
