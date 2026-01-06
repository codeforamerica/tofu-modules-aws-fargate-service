moved {
  from = module.otel_config.aws_ssm_parameter.this[0]
  to   = aws_ssm_parameter.otel_config
}

moved {
  from = aws_cloudwatch_log_group.service
  to   = aws_cloudwatch_log_group.this["service"]
}
