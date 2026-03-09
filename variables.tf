variable "appconfig_agent_environment_variables" {
  type        = map(string)
  description = <<-EOT
    Environment variables for the AppConfig Agent sidecar. Use this to
    configure agent behavior such as PREFETCH_LIST, LOG_LEVEL, or
    POLL_INTERVAL. Only used when `enable_appconfig_agent` is `true`.
    EOT
  default     = {}
}

variable "appconfig_agent_port" {
  type        = number
  description = <<-EOT
    Port for the AppConfig Agent HTTP server. The application retrieves
    configuration by calling http://localhost:<port>. Only used when
    `enable_appconfig_agent` is `true`.
    EOT
  default     = 2772
}

variable "appconfig_agent_version" {
  type        = string
  description = <<-EOT
    Version of the AWS AppConfig Agent image to use. Defaults to `2.x`,
    which tracks the latest 2.x release. Pin to a specific version for
    production stability.
    EOT
  default     = "2.x"
}

variable "container_command" {
  type        = list(string)
  description = "Command to run in the container. Defaults to the image's CMD."
  default     = []
}

variable "container_port" {
  type        = number
  description = "Port that the container listens on."
  default     = 80
}

variable "create_endpoint" {
  type        = bool
  description = "Create an Application Load Balancer for the service."
  default     = true
}

variable "create_repository" {
  type        = bool
  description = "Create an ECR repository for the service."
  default     = true
}

variable "create_version_parameter" {
  type        = bool
  description = <<-EOT
    Create an SSM parameter to store the active version for the image tag.
    EOT
  default     = false
}

variable "cpu" {
  type        = number
  description = "CPU unit for this task."
  default     = 512
}

variable "desired_containers" {
  type        = number
  description = "Desired number of running containers for the service."
  default     = 1
}

variable "domain" {
  type        = string
  description = "Domain name for the service. Required if creating an endpoint."
  default     = ""
}

variable "enable_appconfig_agent" {
  type        = bool
  description = <<-EOT
    Enable an AWS AppConfig Agent sidecar container. The agent caches
    configuration locally and serves it to the application over HTTP,
    enabling live configuration updates without redeployment.
    EOT
  default     = false
}

variable "enable_circuit_breaker" {
  type        = bool
  description = <<-EOT
    Enable ECS deployment circuit breaker to detect failed deployments.
    EOT
  default     = false
}

variable "enable_circuit_breaker_rollback" {
  type        = bool
  description = <<-EOT
    Enable rollback of the service when the circuit breaker is triggered.
    This will roll back the service to the previous version. Only used if
    `enable_circuit_breaker` is `true`.
    EOT
  default     = false
}

variable "enable_container_insights_enhanced" {
  type        = bool
  description = "Enable enhanced container insights for the service."
  default     = true
}

variable "enable_execute_command" {
  type        = bool
  description = "Enable ECS Exec for tasks within the service."
  default     = false
}

variable "environment" {
  type        = string
  description = "Environment for the deployment."
  default     = "dev"
}

variable "environment_secrets" {
  type        = map(string)
  description = <<-EOT
    Secrets to be injected as environment variables on the container. Should be
    in the same format as `environment_secrets`.
    EOT
  default     = {}
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables to set on the container."
  default     = {}
}

variable "execution_policies" {
  type        = list(string)
  description = "Additional policies to add to the task execution role."
  default     = []
}

variable "force_delete" {
  type        = bool
  description = <<-EOT
    Force deletion of resources. If changing to true, be sure to apply before
    destroying.
    EOT
  default     = false
}

variable "force_new_deployment" {
  type        = bool
  description = "Force a new task deployment of the service."
  default     = false
}

variable "health_check_grace_period" {
  type        = number
  description = <<-EOT
    Time, in seconds, after a container comes into service before health checks
    must pass.
    EOT
  default     = 300
}

variable "health_check_path" {
  type        = string
  description = "Application path to use for health checks."
  default     = "/health"
}

variable "hosted_zone_id" {
  type        = string
  description = <<-EOT
    ID of the hosted zone for the domain, leave empty to have this module look
    it up.
    EOT
  default     = null
}

variable "image_tag" {
  type        = string
  description = "Tag for the image to be deployed."
  default     = "latest"
}

variable "image_url" {
  type        = string
  description = <<-EOT
    Source for the image to be deployed. Required if not creating a repository.
    EOT
  default     = ""
}

variable "image_tags_mutable" {
  type        = bool
  description = "Whether image tags in the repository can be mutated."
  default     = false
}

variable "ingress_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks to allow ingress from."
  default     = []
}

variable "ingress_prefix_list_ids" {
  type        = list(string)
  description = "List of prefix list IDs to allow ingress from."
  default     = []
}

variable "key_recovery_period" {
  type        = number
  default     = 30
  description = <<-EOT
    Recovery period for deleted KMS keys in days. Must be between `7` and `30`.
    EOT

  validation {
    condition     = var.key_recovery_period > 6 && var.key_recovery_period < 31
    error_message = "Recovery period must be between 7 and 30."
  }
}

variable "logging_bucket" {
  type        = string
  description = <<-EOT
    S3 bucket to use for logging. If not provided, load balancer logs will not
    be created.
    EOT
  default     = null
}

variable "logging_bucket_prefix" {
  type        = string
  description = "Prefix to store logs under in the logging bucket."
  default     = null
}

variable "logging_key_id" {
  type        = string
  description = "KMS key ID for encrypting logs."
}

variable "log_retention_period" {
  type        = number
  description = "Retention period for CloudWatch Logs, in days."
  default     = 30
}

variable "manage_performance_log_group" {
  type        = bool
  description = <<-EOT
    Whether to manage the container insights performance log group for the
    service. Will default to `true` in a future release.
    EOT
  default     = false
}

variable "memory" {
  type        = number
  description = "Memory for this task."
  default     = 1024
}

variable "oidc_settings" {
  type = object({
    client_id              = optional(string, null)
    client_secret          = optional(string, null)
    client_secret_arn      = optional(string, null)
    authorization_endpoint = string
    issuer                 = string
    token_endpoint         = string
    user_info_endpoint     = string
  })
  description = "OIDC connection settings for the service endpoint."
  sensitive   = true
  default     = null

  validation {
    condition = (
      var.oidc_settings == null ||
      (try(var.oidc_settings.client_id, null) != null && try(var.oidc_settings.client_secret, null) != null) ||
      try(var.oidc_settings.client_secret_arn, null) != null
    )
    error_message = "Client ID and secret, or a secret ARN must be set."
  }
}

variable "otel_collector_version" {
  type        = string
  description = <<-EOT
    Version of the AWS Distro for OpenTelemetry (ADOT) Collector to use.
    Defaults to `latest`, but it's recommended to pin this to a specific
    version.
    EOT
  default     = "latest"
}

variable "otel_config" {
  type        = string
  description = <<-EOT
    Custom configuration, in YAML format, for the OpenTelemetry collector. If
    left empty, a default configuration will be used that sends all metrics,
    logs, and traces to the appropriate AWS services.
    EOT
  default     = null
}

variable "otel_log_level" {
  type        = string
  description = "Log level for the OpenTelemetry collector."
  default     = "info"
}

variable "otel_secrets" {
  type        = map(string)
  description = <<-EOT
    Secrets to be injected as environment variables into the OpenTelemetry
    collector container. This is primarily used alongside a custom
    `otel_config`. Should be in the same format as `environment_secrets`.
    EOT
  default     = {}
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets."
}

variable "project" {
  type        = string
  description = "Project that these resources are supporting."

  validation {
    condition     = length(var.project) + length(var.environment) + length(var.service) <= 57
    error_message = <<-EOT
      Project, environment, and service names must be less than 57 characters, combined.
      Project: ${var.project} (${length(var.project)} characters)
      Environment: ${var.environment} (${length(var.environment)} characters)
      Service: ${var.service} (${length(var.service)} characters)
      Total: ${length(var.project) + length(var.environment) + length(var.service)} characters
    EOT
  }
}

variable "project_short" {
  type        = string
  description = <<-EOT
    Short name for the project. Used in resource names with character limits.
    EOT
}

variable "public" {
  type        = bool
  description = "Whether the service should be exposed to the public Internet."
  default     = false
}

variable "public_subnets" {
  type        = list(string)
  description = <<-EOT
    List of public subnets. Required when creating a public endpoint.
    EOT
  default     = []
}

variable "repository_arn" {
  type        = string
  description = <<-EOT
    ARN of the ECR repository the image resides in. Only required if using a
    private repository, but not creating it here.
    EOT
  default     = null
}

# TODO: Support rotation.
variable "secrets_manager_secrets" {
  type = map(object({
    create_random_password = optional(bool, false)
    description            = string
    recovery_window        = optional(number, 30)
    start_value            = optional(string, "{}")
  }))

  description = "List of Secrets Manager secrets to create."
  default     = {}
}

variable "service" {
  type        = string
  description = <<-EOT
    Service that these resources are supporting. Example: 'api', 'web', 'worker'
    EOT
}

variable "service_short" {
  type        = string
  description = <<-EOT
    Short name for the service. Used in resource names with character limits.
    EOT
}

variable "stats_prefix" {
  type        = string
  description = "Prefix for statsd metrics. Defaults to `project`/`service`."
  default     = ""
}

variable "subdomain" {
  type        = string
  description = "Optional subdomain for the service."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}

variable "task_policies" {
  type        = list(string)
  description = "Additional policies to add to the task role."
  default     = []
}

variable "use_target_group_port_suffix" {
  type        = bool
  description = <<-EOT
    Whether to use the listener port as a suffix for the ALB listener rule.
    Useful if you way need to replace the target group at some point.
    CAUTION: This will default to true in a future release.
  EOT
  default     = false
}

variable "untagged_image_retention" {
  type        = number
  description = "Retention period (after push) for untagged images, in days."
  default     = 14
}

variable "version_parameter" {
  type        = string
  description = "Optional SSM parameter to use for the image tag."
  default     = null
}

variable "volumes" {
  type = map(object({
    mount = string
    type  = optional(string, "persistent")
    name  = optional(string, null)
  }))
  description = "Volumes to mount in the container."
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "Id of the VPC to deploy into."
}

variable "wait_for_steady_state" {
  type        = bool
  description = <<-EOT
    Whether to wait for the service to reach a steady state before considering
    the deployment successful. It's highly recommend that you set
    `enable_circuit_breaker` to `true` when using this option to avoid OpenTofu
    from timing out.
    EOT
  default     = false
}
