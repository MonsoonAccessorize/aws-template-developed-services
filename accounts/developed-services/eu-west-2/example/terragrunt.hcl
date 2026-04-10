include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/example-module"
}

locals {
  environment        = get_env("ENVIRONMENT", "test")
  log_retention_days = local.environment == "prod" ? 90 : 14
}

inputs = {
  name               = "example-service"
  log_retention_days = local.log_retention_days
  tags = {
    Service = "ExampleService"
  }
}
