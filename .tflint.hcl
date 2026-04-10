# TFLint configuration for AWS Core Infrastructure
# https://github.com/terraform-linters/tflint

config {
  # Call module inspection type
  call_module_type = "all" # Options: "all", "local", "none"

  # Force provider version constraints
  force = false

  # Disable color output for CI/CD
  disabled_by_default = false
}

# Enable the AWS plugin
plugin "aws" {
  enabled = true
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Enable Terraform plugin for general best practices
plugin "terraform" {
  enabled = true
  version = "0.10.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

# AWS-specific rules
rule "aws_resource_missing_tags" {
  enabled = false
  # Disabled: All mandatory tags (ManagedBy, Repository, Environment, CostCenter, Owner, map-migrated)
  # are automatically applied via provider default_tags in root.hcl
  # Purpose tag is optional and not enforced by TFLint
}

rule "aws_iam_policy_document_gov_friendly_arns" {
  enabled = false # Not using GovCloud
}

rule "aws_s3_bucket_name" {
  enabled = true
  regex   = "^[a-z0-9][a-z0-9-]*[a-z0-9]$"
}

rule "aws_db_instance_previous_type" {
  enabled = true
}

rule "aws_elasticache_cluster_previous_type" {
  enabled = true
}

rule "aws_instance_previous_type" {
  enabled = true
}

# Terraform best practices
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = false # Can be overly strict, especially with data sources used in outputs
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled          = true
  style            = "flexible"
  default_branches = ["main", "master"]
}

rule "terraform_naming_convention" {
  enabled = true

  # Variable naming
  variable {
    format = "snake_case"
  }

  # Local value naming
  locals {
    format = "snake_case"
  }

  # Output naming
  output {
    format = "snake_case"
  }

  # Resource naming
  resource {
    format = "snake_case"
  }

  # Data source naming
  data {
    format = "snake_case"
  }

  # Module naming
  module {
    format = "snake_case"
  }
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = false # Disabled for bootstrap configs which have different structure
}

rule "terraform_workspace_remote" {
  enabled = false # We use Terragrunt for remote state
}

# Disable rules that conflict with Terragrunt patterns
rule "terraform_unused_required_providers" {
  enabled = false # Terragrunt generates provider configs
}
