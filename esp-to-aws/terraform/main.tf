provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Project = "esp2aws"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "luk-iac-nc"
    key    = "esp2aws"
    region = "eu-central-1"
  }
}
