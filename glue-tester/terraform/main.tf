provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Project = "glue-tester-luke"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "luk-iac-nc"
    key    = "glue-tester-luke"
    region = "eu-central-1"
  }
}

