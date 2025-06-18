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
  description = "Create an SSM parameter to store the active version for the image tag."
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
  description = "Secrets to be injected as environment variables on the container."
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
  description = "Force deletion of resources. If changing to true, be sure to apply before destroying."
  default     = false
}

variable "health_check_grace_period" {
  type        = number
  description = "Time, in seconds, after a container comes into service before health checks must pass."
  default     = 300
}

variable "health_check_path" {
  type        = string
  description = "Application path to use for health checks."
  default     = "/health"
}

variable "image_tag" {
  type        = string
  description = "Tag for the image to be deployed."
  default     = "latest"
}

variable "image_url" {
  type        = string
  description = "Source for the image to be deployed. Required if not creating a repository."
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

variable "key_recovery_period" {
  type        = number
  default     = 30
  description = "Recovery period for deleted KMS keys in days. Must be between 7 and 30."

  validation {
    condition     = var.key_recovery_period > 6 && var.key_recovery_period < 31
    error_message = "Recovery period must be between 7 and 30."
  }
}

variable "logging_key_id" {
  type        = string
  description = "KMS key ID for encrypting logs."
}

variable "memory" {
  type        = number
  description = "Memory for this task."
  default     = 1024
}

variable "oidc_settings" {
  type = object({
    client_id              = string
    client_secret          = string
    authorization_endpoint = string
    issuer                 = string
    token_endpoint         = string
    user_info_endpoint     = string
  })

  description = "OIDC settings for the service. Required if `internal` is true."
  default     = null
}

variable "otel_log_level" {
  type        = string
  description = "Log level for the OpenTelemetry collector."
  default     = "info"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets."
}

variable "project" {
  type        = string
  description = "Project that these resources are supporting."
}

variable "public" {
  type        = bool
  description = "Whether the service should be exposed to the public Internet."
  default     = false
}

variable "project_short" {
  type        = string
  description = "Short name for the project. Used in resource names with character limits."
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnets. Required when creating a public endpoint."
  default     = []
}

variable "repository_arn" {
  type        = string
  description = "ARN of the ECR repository the image resides in. Only required if using a private repository, but not creating it here."
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
  description = "Service that these resources are supporting. Example: 'api', 'web', 'worker'"
}

variable "service_short" {
  type        = string
  description = "Short name for the service. Used in resource names with character limits."
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

variable "vpc_id" {
  type        = string
  description = "Id of the VPC to deploy into."
}
