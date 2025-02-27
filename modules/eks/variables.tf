variable "aws_region" {
  description = "Region where main resources should be created."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Cluster name."
  type        = string
  default     = "test-cluster"
}

variable "subnets" {
  description = "Subnets where to deploy cluster."
  type        = list(string)
  default     = ["subnet-1234", ]
}

variable "vpc_id" {
  description = "VPC to launch cluster."
  type        = string
  default     = "vpc-61677"
}
