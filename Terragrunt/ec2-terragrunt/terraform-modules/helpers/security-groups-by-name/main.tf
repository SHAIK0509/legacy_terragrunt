variable "vpc_id" {
  description = "The vpc id in which to search for named security groups"
  type        = string
}

variable "security_groups" {
  description = "A list of named security groups"
  type        = list(string)
  default     = []
}

data "aws_security_group" "this" {
  for_each = toset(var.security_groups)

  name   = each.key
  vpc_id = var.vpc_id
}

output "security_group_ids" {
  value = [for sg in values(data.aws_security_group.this) : sg.id]
}
