terraform {
  backend "s3" {
    bucket         = "terrabucket-v2"
    key            = "terraform.tfstate"
    region         = "eu-west-2"

  }
}