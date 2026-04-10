terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

resource "aws_ssm_parameter" "example" {
  name        = "/adena-aws-template/${var.name}/example"
  type        = "String"
  value       = "template-placeholder"
  description = "Log retention: ${var.log_retention_days} days"
  tags        = var.tags
}
