locals {
  fqdn           = var.subdomain != "" ? "${var.subdomain}.${var.domain}" : var.domain
  image_url      = var.create_repository ? module.ecr["this"].repository_url : var.image_url
  prefix         = "${var.project}-${var.environment}-${var.service}"
  prefix_short   = "${var.project_short}-${var.environment}-${var.service_short}"
  repository_arn = var.create_repository ? module.ecr["this"].repository_arn : var.repository_arn
  stats_prefix   = var.stats_prefix != "" ? var.stats_prefix : "${var.project}/${var.service}"
  oidc_settings  = var.oidc_settings == null ? {} : { authenticate_oidc : var.oidc_settings }

  authorized_secrets = [
    for key, value in var.environment_secrets :
    (startswith(value, "arn:")
      ? join(":", slice(split(":", value), 0, length(split(":", value)) - 1))
    : module.secrets_manager[split(":", value)[0]].secret_arn)
  ]

  # Determine the correct image tag based on either an SSM parameter or the
  # supplied input value.
  version_parameter = (var.create_version_parameter
    ? aws_ssm_parameter.version["this"].name
  : var.version_parameter)
  image_tag = (length(data.aws_ssm_parameter.version) > 0
    ? data.aws_ssm_parameter.version[local.version_parameter].insecure_value
  : var.image_tag)
}
