# debug module

A do-nothing module for testing inputs and outputs, implemented in a way compatible with terragrunt.

## Examples

### Simple Usage

```hcl
# infrastructure-live/dev/us-east-1/dev/debug

inputs = {
    data = {
        variable = "variable"
    }
}
```

### Terragrunt Inheritance

```hcl
# infrastructure-live/dev/terragrunt.hcl

...

inputs = {
    parent = {
        variable_from_parent = "parent"
    }
}
```

```hcl
# infrastructure-live/dev/us-east-1/dev/debug/terragrunt.hcl

...

inputs = {
    child = {
        variable_from_child = "child"
    }
}
```
