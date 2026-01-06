locals {
  fqdn              = var.subdomain != "" ? "${var.subdomain}.${var.domain}" : var.domain
  image_url         = var.create_repository ? module.ecr["this"].repository_url : var.image_url
  prefix            = join("-", compact([var.project, var.environment, var.service]))
  prefix_short      = join("-", compact([var.project_short, var.environment, var.service_short]))
  repository_arn    = var.create_repository ? module.ecr["this"].repository_arn : var.repository_arn
  stats_prefix      = var.stats_prefix != "" ? var.stats_prefix : "${var.project}/${var.service}"
  target_group_name = "${local.prefix_short}-${var.use_target_group_port_suffix ? var.container_port : "app"}"

  alb_security_groups = compact([
    module.endpoint_security_group.security_group_id,
    length(var.ingress_prefix_list_ids) > 0 ? module.prefix_security_group["this"].security_group_id : null
  ])

  # Define log groups to be managed.
  log_groups = {
    service     = join("/", compact(["/aws/ecs", var.project, var.environment, var.service]))
    performance = var.manage_performance_log_group ? "/aws/ecs/containerinsights/${local.prefix}/performance" : null
  }
  managed_log_groups = {
    for key, value in local.log_groups :
    key => value if value != null
  }

  oidc_settings = var.oidc_settings == null ? {} : {
    authenticate_oidc : merge(var.oidc_settings, length(data.aws_secretsmanager_secret_version.oidc) == 0 ? {} : {
      client_id     = jsondecode(data.aws_secretsmanager_secret_version.oidc["this"].secret_string)["client_id"]
      client_secret = jsondecode(data.aws_secretsmanager_secret_version.oidc["this"].secret_string)["client_secret"]
    })
  }

  authorized_secrets = [
    for key, value in var.environment_secrets :
    (startswith(value, "arn:")
      ? (length(split(":", value)) > 7 ? join(":", slice(split(":", value), 0, 7)) : value)
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
