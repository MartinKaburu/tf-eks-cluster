data "terraform_remote_state" "eks_state" {
  backend = "s3"

  config = {
    bucket = "tfstatetestbckt"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
  }
}
