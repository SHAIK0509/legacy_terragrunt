variable "name" {
  description = "The name of the task definition"
  type        = string
}

variable "container_definitions" {
  description = "A jsonencoded list of ecs container definitions"
  type        = string
}

variable "allowed_deployment_environments" {
  description = "A list of allowed environments"
  type        = list(string)
  default     = ["dev", "stage", "prod", "shared-services"]
}

variable "template_variables" {
  description = "A map of placeholder values to interpolate in various helper module resources"
  type        = any
  default     = {}
}

variable "aws_region" {
  description = "The AWS region in which to create resources (and the ecr registry)"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
  type        = string
}

variable "ecr_account_id" {
  description = "The account id used to determine if an ecr repo should be included in a tasks execution role"
  type        = string
  default     = "788386357094"
}

variable "cpu" {
  description = "The CPU assignment for the fargate task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "The MEMORY assignment for the fargate task"
  type        = number
  default     = 512
}

variable "task_role" {
  description = "The jsonencoded task role definition (i.e. iam-role format)"
  type        = string
  default     = "{}"
}

variable "kms_arns" {
  description = "A list of kms arns that this task needs to decrypt secrets (defaults to alias/aws/ssm)"
  type        = list(string)
  default     = []
}

variable "log_retention_in_days" {
  description = "The number of days to retain logs streamed to the log group"
  type        = number
  default     = 7
}

variable "efs_subnets" {
  description = "The subnets in which efs volumes should be created"
  type        = list(string)
  default     = []
}

variable "efs_volumes" {
  description = "A jsonencoded map of volume settings for provisioning an efs filesystem"
  type        = string
  default     = "{}"
}

variable "efs_volumes_backup_schedule" {
  description = "A CRON expression specifying when AWS Backup initiates a backup job (default: disabled)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to apply to this task definition"
  type        = map
  default     = {}
}
