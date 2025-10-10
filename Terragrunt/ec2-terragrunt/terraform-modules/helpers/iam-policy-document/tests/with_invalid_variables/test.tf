module "templated_policy" {
  source = "./modules/helpers/iam-policy-document"

  statements = jsonencode({
    AllowECRImagePull = {
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
      ]
      resources = ["$${ecr_url}"]
    }
  })

  template_variables = {}
}

