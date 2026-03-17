resource "aws_cloudwatch_log_group" "this" {
  for_each = local.managed_log_groups

  name              = each.value
  retention_in_days = var.log_retention_period
  kms_key_id        = var.logging_key_id

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "events" {
  for_each = var.enable_event_capturing ? toset(["this"]) : toset([])

  name        = "${local.prefix}-ecs-events"
  description = "Capture ECS events for the ${var.project} ${var.service} service."
  event_pattern = jsonencode({
    source = ["aws.ecs"]
    detail = {
      clusterArn = [module.ecs.arn]
    }
  })
}

resource "aws_cloudwatch_event_target" "events" {
  for_each = var.enable_event_capturing ? toset(["this"]) : toset([])

  target_id = "${local.prefix}-ecs-events"
  rule      = aws_cloudwatch_event_rule.events["this"].name
  arn       = aws_cloudwatch_log_group.this["events"].arn
}
