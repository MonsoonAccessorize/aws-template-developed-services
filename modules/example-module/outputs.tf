output "ssm_parameter_arn" {
  description = "ARN of the example SSM parameter."
  value       = aws_ssm_parameter.example.arn
}
