variable "data" {
  type    = any
  default = {}
}

variable "parent" {
  type    = any
  default = {}
}

variable "child" {
  type    = any
  default = {}
}


output "data" {
  value = merge(var.data, {
    child  = var.child
    parent = var.parent
  })
}
