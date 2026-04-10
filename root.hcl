# TEMPLATE REPO - root.hcl
# Before use, replace:
#   - Repository tag value
#   - accounts.yml account IDs
#   - REPLACE_WITH_STATE_BUCKET_NAME      (S3 bucket name for Terraform remote state)
#   - REPLACE_WITH_STATE_ACCOUNT_ID       (AWS account ID where the state bucket lives)
#   - REPLACE_WITH_STATE_ACCESS_ROLE_NAME (IAM role assumed to read/write the state bucket)

locals {
  accounts_config = yamldecode(file("${get_repo_root()}/accounts.yml"))

  account_ids = {
    for account_name, account_config in local.accounts_config.accounts :
    account_name => account_config.id
  }

  tag_config = yamldecode(file("${get_repo_root()}/tags.yml"))

  aws_region = "eu-west-2"

  # Account is resolved from the ENVIRONMENT env var set by CI (test|prod).
  # This allows a single module folder to serve both environments.
  env_to_account = {
    test = "example-test"
    prod = "example-prod"
  }

  account_name = lookup(local.env_to_account, get_env("ENVIRONMENT", "test"), "example-test")
  account_id   = lookup(local.account_ids, local.account_name, local.account_ids.shared_services)

  account_display_names = {
    example-test = "ExampleTest"
    example-prod = "ExampleProd"
  }

  common_tags = {
    ManagedBy  = "Terraform"
    Repository = "REPLACE_WITH_REPO_NAME" # TEMPLATE: Update to consuming repo name
    Account    = lookup(local.account_display_names, local.account_name, "Unknown")
  }
}

# Terragrunt ≥ 0.99 mangles role keywords in generated files:
#   • Any generate block whose label or path contains "backend" has assume_role/role_arn
#     rewritten to __assume_role__/__role_arn__ placeholders.
#   • The block form `assume_role { ... }` anywhere in a generated file triggers the
#     same mangling; the attribute form `assume_role = { ... }` bypasses it.
#
# Solution: split the S3 backend configuration across two generated files.
#
#   backend.tf       — bare `terraform { backend "s3" {} }` declaration only
#                      (no role keywords → no mangling)
#   state_config.hcl — full backend settings using `assume_role = { ... }` (attribute
#                      form); label and path intentionally avoid the word "backend";
#                      passed to `terraform init` via the extra_arguments block below.

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<TFEOF
terraform {
  backend "s3" {}
}
TFEOF
}

generate "state_config" {
  path      = "state_config.hcl"
  if_exists = "overwrite_terragrunt"

  contents = <<TFEOF
bucket         = "REPLACE_WITH_STATE_BUCKET_NAME"
key            = "${path_relative_to_include()}/terraform.tfstate"
region         = "${local.aws_region}"
encrypt        = true
dynamodb_table = "terraform-state-locks"

assume_role = {
  role_arn = "arn:aws:iam::REPLACE_WITH_STATE_ACCOUNT_ID:role/REPLACE_WITH_STATE_ACCESS_ROLE_NAME"
}
TFEOF
}

terraform {
  extra_arguments "state_config_file" {
    commands  = ["init"]
    arguments = ["-backend-config=state_config.hcl"]
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<TFEOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
TFEOF
}

inputs = {
  aws_region   = local.aws_region
  account_ids  = local.account_ids
  account_id   = local.account_id
  account_name = local.account_name
  common_tags  = local.common_tags
}
