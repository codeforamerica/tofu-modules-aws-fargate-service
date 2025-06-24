data "aws_caller_identity" "identity" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_route53_zone" "domain" {
  for_each = var.create_endpoint ? toset(["this"]) : toset([])

  name = var.domain
}

data "aws_secretsmanager_secret_version" "oidc" {
  for_each = try(var.oidc_settings.client_secret_arn, null) != null ? toset(["this"]) : toset([])

  secret_id = var.oidc_settings.client_secret_arn
}

data "aws_ssm_parameter" "version" {
  depends_on = [aws_ssm_parameter.version]
  for_each   = local.version_parameter != null ? toset([local.version_parameter]) : []

  name = each.value
}

data "aws_vpc" "current" {
  id = var.vpc_id
}
