module "assert_equals_success" {
  source = "./modules/helpers/assert"

  actual    = "one,two"
  expected  = "one"
  condition = "contains"
}
