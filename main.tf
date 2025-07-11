module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.2"

  for_each = var.create_repository ? toset(["this"]) : toset([])

  repository_name                 = local.prefix
  repository_image_scan_on_push   = true
  repository_encryption_type      = "KMS"
  repository_force_delete         = var.force_delete
  repository_image_tag_mutability = var.image_tags_mutable ? "MUTABLE" : "IMMUTABLE"
  repository_kms_key              = aws_kms_key.fargate.arn
  repository_lifecycle_policy = jsonencode(yamldecode(templatefile(
    "${path.module}/templates/repository-lifecycle.yaml.tftpl", {
      untagged_image_retention : var.untagged_image_retention
    }
  )))

  tags = var.tags
}

resource "aws_ssm_parameter" "version" {
  for_each = var.create_version_parameter ? toset(["this"]) : []

  name           = "/${var.project}/${var.environment}/${var.service}/version"
  description    = "Current version of ${var.project} - ${var.environment} ${var.service}"
  type           = "String"
  insecure_value = var.image_tag

  tags = var.tags

  lifecycle {
    ignore_changes = [insecure_value]
  }
}

# If this is a public load balancer, we need to allow all traffic.
#trivy:ignore:avd-aws-0107
module "endpoint_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name   = "${local.prefix}-endpoint"
  vpc_id = var.vpc_id

  # Ingress for HTTP
  ingress_cidr_blocks = concat(
    [var.public ? "0.0.0.0/0" : data.aws_vpc.current.cidr_block],
    var.ingress_cidrs
  )
  ingress_rules = ["http-80-tcp", "https-443-tcp"]

  # Allow all egress
  egress_cidr_blocks      = [data.aws_vpc.current.cidr_block]
  egress_rules            = ["all-all"]
  egress_ipv6_cidr_blocks = []
  egress_with_cidr_blocks = var.oidc_settings == null ? [] : [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "IdP access for OIDC authentication."
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = var.tags
}

# TODO: Determine how we can best restrict the egress rules.
#trivy:ignore:avd-aws-0104
module "task_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name   = "${local.prefix}-endpoint"
  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [{
    from_port                = var.container_port
    to_port                  = var.container_port
    protocol                 = "tcp"
    description              = "${var.service} access from the load balancer."
    source_security_group_id = module.endpoint_security_group.security_group_id
  }]

  # Allow all egress.
  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = ["::/0"]
  egress_rules            = ["all-all"]

  tags = var.tags
}

module "ecs" {
  source  = "HENNGE/ecs/aws"
  version = "~> 4.2"

  name                      = local.prefix
  capacity_providers        = ["FARGATE"]
  enable_container_insights = true

  tags = var.tags
}

module "ecs_service" {
  source     = "HENNGE/ecs/aws//modules/simple/fargate"
  version    = "~> 5.1"
  depends_on = [module.alb, module.ecs]

  name                              = local.prefix
  cluster                           = module.ecs.arn
  container_port                    = var.container_port
  container_name                    = local.prefix
  cpu                               = var.cpu
  memory                            = var.memory
  desired_count                     = var.desired_containers
  vpc_subnets                       = var.private_subnets
  target_group_arn                  = var.create_endpoint ? module.alb["this"].target_groups["endpoint"].arn : null
  security_groups                   = [module.task_security_group.security_group_id]
  iam_daemon_role                   = aws_iam_role.execution.arn
  iam_task_role                     = aws_iam_role.task.arn
  enable_execute_command            = var.enable_execute_command
  health_check_grace_period_seconds = var.health_check_grace_period
  force_delete                      = var.force_delete

  container_definitions = jsonencode(yamldecode(templatefile(
    "${path.module}/templates/container_definitions.yaml.tftpl", {
      name              = local.prefix
      cpu               = var.cpu - 256
      memory            = var.memory - 512
      image             = "${local.image_url}:${local.image_tag}"
      container_command = var.container_command
      container_port    = var.container_port
      log_group         = aws_cloudwatch_log_group.service.name
      region            = data.aws_region.current.name
      namespace         = "${var.project}/${var.service}"
      env_vars          = var.environment_variables
      otel_log_level    = var.otel_log_level
      otel_ssm_arn      = module.otel_config.ssm_parameter_arn
      volumes           = var.volumes

      # Split defined secrets on ":" and use the name to get the arn.
      env_secrets = {
        for key, value in var.environment_secrets :
        key => split(":", value)[0] == "arn"
        ? "${join(":", slice(split(":", value), 0, length(split(":", value)) - 1))}:${split(":", value)[length(split(":", value)) - 1]}::"
        : "${module.secrets_manager[split(":", value)[0]].secret_arn}:${split(":", value)[1]}::"
      }
    }
  )))

  task_volume_configurations = [for k, v in var.volumes : {
    name = k
    efs_volume_configuration = {
      file_system_id        = module.efs[k].id
      root_directory        = "/"
      transition_encryption = "ENABLED"
    }
    }
  ]

  tags = var.tags
}
