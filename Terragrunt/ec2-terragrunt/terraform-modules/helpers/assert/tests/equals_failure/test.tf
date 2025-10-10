module "assert_equals_failure" {
  source = "./modules/helpers/assert"

  actual   = 1
  expected = 0
}

