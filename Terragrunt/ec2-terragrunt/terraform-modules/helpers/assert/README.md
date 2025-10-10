## helpers/assert

Terraform's existing input validation is rather inflexible and does not provide a mechanism for  
custom error handling or messaging. This module leverages the `jq` program for this purpose.

This approach was shamelessly stolen from https://github.com/ahl/terrassert with slight  
modifications.

Usage:

```hcl
// check that an input list is of an expected length
module "assert_input_has_2_subnets" {
  source = "../helpers/assert"

  actual   = length(var.subnets)
  expetend = 2
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| external | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| actual | The actual value to be checked | `string` | n/a | yes |
| condition | The type of check to perform, 'equals', 'contains' | `string` | `"equals"` | no |
| errors | A map of assertion errors to display if an assertion fails (dollar signs must be escaped with `$$`) | `map(string)` | <pre>{<br>  "contains": "assertion failure: <actual> contains <expected>\n  expected: ${expected}\n  actual:   ${actual}",<br>  "equals": "assertion failure: <expected> == <actual>\n  expected: ${expected}\n  actual:   ${actual}"<br>}</pre> | no |
| expected | The expected value to be compared with actual | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| status | n/a |

