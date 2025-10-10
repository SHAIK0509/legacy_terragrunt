variable "name" {
  description = "The name of the NLB. Do not include the environment name since this module will automatically append it to the value of this variable."
  type        = string
}

variable "internal" {
  description = "If the ALB should only accept traffic from within the VPC, set this to true. If it should accept traffic from the public Internet, set it to false."
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "The name of the VPC to deploy into"
  type        = string
}

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "terraform_state_aws_region" {
  description = "The AWS region of the S3 bucket used to store Terraform remote state"
  type        = string
}

variable "terraform_state_s3_bucket" {
  description = "The name of the S3 bucket used to store Terraform remote state"
  type        = string
}

variable "remote_state_paths" {
  description = "A map of names to paths relative to region/vpc-name"
  type        = map(string)
}

variable "enable_deletion_protection" {
  description = "A boolean that indicates whether the nlb should have deletion protection enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to created resources"
  type        = map(string)
  default     = {}
}
