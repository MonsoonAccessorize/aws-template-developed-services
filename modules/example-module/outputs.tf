output "execution_role_arn" {
  description = "ARN of the Lambda execution IAM role."
  value       = aws_iam_role.lambda_execution.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.lambda.name
}
