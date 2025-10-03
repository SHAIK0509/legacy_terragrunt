# Legacy Terragrunt Infrastructure

This repository manages infrastructure using [Terragrunt](https://terragrunt.gruntwork.io/) and [Terraform](https://www.terraform.io/). It provides modular, environment-based deployments for AWS resources.
## Structure

```
Terragrunt/
   ec2-terragrunt/
      live/
         dev/
            terragrunt.hcl
         prod/
            terragrunt.hcl
         stage/
            terragrunt.hcl
         Makefile
      terraform-modules/
         ec2/
            main.tf
            outputs.tf
            variables.tf
jenkinsfile
ReadMe.md
```

## Usage

### Prerequisites
- [Terraform](https://www.terraform.io/) (version specified in Makefile)
- [Terragrunt](https://terragrunt.gruntwork.io/) (version specified in Makefile)
- AWS credentials configured

### Makefile Commands
Run these from the `Terragrunt/ec2-terragrunt/live` directory:

- **Plan:**
   ```sh
   make plan ENV=dev
   ```
   Runs `terragrunt plan` for the specified environment (`dev`, `prod`, `stage`).

- **Apply:**
   ```sh
   make apply ENV=dev
   ```
   Applies changes for the specified environment.

- **Destroy:**
   ```sh
   make destroy ENV=dev
   ```
   Destroys resources for the specified environment.

- **Output:**
   ```sh
   make output ENV=dev
   ```
   Shows Terraform outputs for the specified environment.

- **Clean:**
   ```sh
   make clean
   ```
   Removes binaries and cache files.

### Jenkins Pipeline
The `jenkinsfile` automates plan, apply, and destroy actions. Select the environment and action (`plan`, `apply`, `destroy`) when running the pipeline.

## Contributing
1. Fork the repo
2. Create a feature branch
3. Commit your changes
4. Open a pull request

## License
MIT

## Maintainers
- SHAIK0509