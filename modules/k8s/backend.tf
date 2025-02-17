terraform {
  backend "s3" {
    bucket     = "tfstatetestbckt"
    key        = "k8s/terraform.tfstate"

    region     = "ap-south-1"

    encrypt    = true
  }
}
