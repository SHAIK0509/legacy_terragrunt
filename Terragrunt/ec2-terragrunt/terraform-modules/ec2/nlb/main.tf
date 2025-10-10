module "security_group" {
  source = "../security-group"

  name = var.name

  vpc_id = module.remote.states.vpc.vpc_id

  rules = jsonencode([])

  tags = var.tags
}

module "remote" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/remote-state"

  terraform_state_s3_bucket  = var.terraform_state_s3_bucket
  terraform_state_aws_region = var.terraform_state_aws_region

  relative_paths = var.remote_state_paths
  relative_from  = "${var.aws_region}/${var.vpc_name}"
}


resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "network"
  security_groups    = [module.security_group.security_group.id]

  subnets = (
    var.internal
    ? module.remote.states.vpc.private_app_subnet_ids
    : module.remote.states.vpc.public_subnet_ids
  )

  enable_deletion_protection = var.enable_deletion_protection

  tags = var.tags
}
