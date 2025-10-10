## helpers/remote-state

This helper module reduces the amount of terraform code one must write to utilize remote state  
outputs from multiple terragrunt hierarchies.

### Usage

We accept input in two forms, `regular` and `relative`. The `regular` form expects a value in the
`paths` input. For example,

```hcl
# terragrunt.hcl
inputs = {
    paths = {
        vpc = "us-east-1/dev/vpc"
        lb = "us-east-1/dev/networking/alb-internal"
    }
}
```

While, the `relative` form expects values for both `relative_paths` and `relative_from`. If one is  
missing or empty, an error is raised on apply. The `relative` form would look something like this:

```hcl
# terragrunt.hcl
inputs = {
    relative_paths = {
        vpc = "vpc"
        lb = "networking/alb-internal"
    }
    relative_from = "us-east-1/dev"
}
```
... or similarly ...

```hcl
# us-east-1/dev/applications/hubot/terragrunt.hcl
inputs = {
    relative_paths = {
        vpc = "../../vpc"
        lb = "../../networking/alb-internal"
    }
    relative_from = path_relative_to_include()
}
```

### Advanced usage

The `required` input takes a list of keys that are expected to exist by the calling module,  
resulting in an error during applies, if not the case, thus short circuiting an apply that cannot  
complete. Its purpose is to validate the proper configuration of the calling module, and avoid a  
commonly difficult to troubleshoot condition. With `regular` form, one might use `required` in the following way:

```hcl
# main.tf
module "remote" {
    source = "./"

    paths = var.remote_state_paths
    required = ["vpc", "lb"]
}
```

Although, `required` works the same way regardless of the form employed, `regular` or `relative`,  
or both at once.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| external | n/a |
| terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| paths | A map of state-name to 'dirname' path of the remote state key in s3 | `map(string)` | `{}` | no |
| relative\_from | The base path of all `relative_path`s provided as input | `string` | `""` | no |
| relative\_paths | A map of state-name to relative path, relative to `relative_from` | `map(string)` | `{}` | no |
| required | The list of keys (basename of the remote state) that are expected to exist by the calling module | `list(string)` | `[]` | no |
| terraform\_state\_aws\_region | The AWS region of the S3 bucket used to store Terraform remote state | `string` | n/a | yes |
| terraform\_state\_s3\_bucket | The name of the S3 bucket used to store Terraform remote state | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| states | A map of collected remote state data |

