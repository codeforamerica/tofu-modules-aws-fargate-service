locals {
  fqdn           = var.subdomain != "" ? "${var.subdomain}.${var.domain}" : var.domain
  image_url      = var.create_repository ? module.ecr["this"].repository_url : var.image_url
  prefix         = "${var.project}-${var.environment}-${var.service}"
  prefix_short   = "${var.project_short}-${var.environment}-${var.service_short}"
  repository_arn = var.create_repository ? module.ecr["this"].repository_arn : var.repository_arn
  stats_prefix   = var.stats_prefix != "" ? var.stats_prefix : "${var.project}/${var.service}"
  target_group_name = "${local.prefix_short}-${var.use_target_group_port_suffix ? var.container_port : "app"}"

  oidc_settings = var.oidc_settings == null ? {} : {
    authenticate_oidc : merge(var.oidc_settings, length(data.aws_secretsmanager_secret_version.oidc) == 0 ? {} : {
      client_id     = jsondecode(data.aws_secretsmanager_secret_version.oidc["this"].secret_string)["client_id"]
      client_secret = jsondecode(data.aws_secretsmanager_secret_version.oidc["this"].secret_string)["client_secret"]
    })
  }

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
