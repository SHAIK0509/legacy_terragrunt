module "policy" {
  source = "./modules/helpers/iam-policy-document"

  statements = jsonencode({
    AllowReadOnlyS3Bucket = {
      actions   = ["s3:Get*", "s3:List"]
      resources = ["arn:aws:s3:::some-s3-bucket"]
    }
  })
}

