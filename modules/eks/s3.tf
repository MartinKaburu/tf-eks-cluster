#resource "aws_s3_bucket" "terraform_state" {
#  bucket = "eks-cluster-tf-state"
#
#}
#
#resource "aws_s3_bucket_versioning" "versioning" {
#  bucket = aws_s3_bucket.terraform_state.id
#
#  versioning_configuration {
#    status = "Enabled"
#  }
#}
