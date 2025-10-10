variable "name" {
  type        = string
  description = "The full name of the service being deployed"
}

variable "log_arns" {
  type        = list(string)
  description = "A list of cloudwatch log group arns used by this task"
  default     = []
}

variable "ecr_arns" {
  type        = list(string)
  description = "A list of ECR repo arns used by this task"
  default     = []
}

variable "kms_arns" {
  type        = list(string)
  description = "A list of kms arns used to decrypt secrets by this task"
  default     = []
}

variable "secrets" {
  type        = list(string)
  description = "The list of parameter store paths for which this task requires access"
  default     = []
}

variable "template_variables" {
  description = "A map of placeholder values to interpolate in the provided IAM policy statements"
  type        = any
  default     = {}
}

variable "managed_policies" {
  description = "A list of managed policy names, with an arn prefix or without"
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to resources created in this module"
  default     = {}
}
