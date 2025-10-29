moved {
  from = module.otel_config.aws_ssm_parameter.this[0]
  to   = aws_ssm_parameter.otel_config
}
