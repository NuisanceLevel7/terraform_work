variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "TerraformCreated"
}

variable "root_arn" {
  type    = string
  default = "arn:aws:iam::736922127837:root"
}

variable "s3_endpoint" {
  type    = string
  default = "vpce-xxxxxxxxxxx"
}


data "aws_caller_identity" "current" {}
