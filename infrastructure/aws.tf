provider "aws" {
  region = "us-west-2"
}

module "aws" {
  source = "./aws"
}
