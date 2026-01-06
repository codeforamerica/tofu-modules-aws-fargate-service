resource "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups

  name              = each.value
  retention_in_days = var.log_retention_period
  kms_key_id        = var.logging_key_id

  tags = var.tags
}
