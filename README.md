# AWS Fargate Service Module

[![Main Checks][badge-checks]][code-checks] [![GitHub Release][badge-release]][latest-release]

This module launches a service on AWS Fargate. It creates a cluster, task
definition, service, and container repository. In addition, it creates the load
balancer, ACM certificate, Route53 records, and security groups needed to expose
the service.

## Usage

Add this module to your `main.tf` (or appropriate) file and configure the inputs
to match your desired configuration. For example:

```hcl
module "fargate_service" {
  source = "github.com/codeforamerica/tofu-modules-aws-fargate-service?ref=1.2.0"

  project       = "my-project"
  project_short = "my-proj"
  environment   = "dev"
  service       = "worker"
  service_short = "wrk"

  domain          = "dev.worker.my-project.org"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  logging_key_id  = module.logging.kms_key_arn
  container_port  = 3000

  environment_variables = {
    RACK_ENV = "development"
  }
}
```

Make sure you re-run `tofu init` after adding the module to your configuration.

```bash
tofu init
tofu plan
```

To update the source for this module, pass `-upgrade` to `tofu init`:

```bash
tofu init -upgrade
```

### Deploying updated container images

When you use OpenTofu to manage your services and tasks, it can become out of
sync if you're deploying new task versions outside of it. To facilitate
deployment of new container images (e.g., application versions, patches, etc.)
this module offers three ways to define the current image version:

1. (Recommended) Use `create_version_parameter` to create and manage an
   (insecure) SSM parameter. The initial value will be set to `image_tag`
   (default "latest"), but updates to the value _must_ occur outside OpenTofu.
   The current value of this parameter will be read when running `tofu`.

   Use your normal CI/CD deployment process to build and push your image. Then
   set the new version tag into the parameter before running `tofu apply`. This
   allows you to completely automate the deployment process if you wish.

1. Use `version_parameter` to specify your own SSM parameter. The task must be
   able to retrieve the value of the parameter. This method allows for the same
   automated deployment process as the previous one, but requires you to create
   and maintain the parameter outside this module.

1. (Default) Use `image_tag` to specify the image tag to deploy. This is the
   default behavior and will be used if neither of the other inputs has been
   set. This requires the `image_tag` input variable to be updated anytime the
   desired version changes.

   When using `create_version_parameter`, `image_tag` will be used to set the
   initial value, but future updates to this variable will be ignored. This
   allows for easier initial deployment and migration to using the SSM
   parameter.

## Inputs

| Name                      | Description                                                                                                     | Type           | Default     | Required    |
|---------------------------|-----------------------------------------------------------------------------------------------------------------|----------------|-------------|-------------|
| logging_key_id            | KMS key to use for log encryption.                                                                              | `string`       | n/a         | yes         |
| private_subnets           | List of private subnet CIDR blocks.                                                                             | `list`         | n/a         | yes         |
| project                   | Name of the project.                                                                                            | `string`       | n/a         | yes         |
| project_short             | Short name for the project. Used in resource names with character limits.                                       | `string`       | n/a         | yes         |
| service                   | Service that these resources are supporting. Example: `"api"`, `"web"`, `"worker"`                              | `string`       | n/a         | yes         |
| service_short             | Short name for the service. Used in resource names with character limits.                                       | `string`       | n/a         | yes         |
| vpc_id                    | Id of the VPC to deploy into.                                                                                   | `string`       | n/a         | yes         |
| public_subnets            | List of public subnet CIDR blocks. Required when creating a public endpoint.                                    | `list`         | n/a         | conditional |
| domain                    | Domain name for service. Required if creating an endpoint. Example: `"staging.service.org"`                     | `string`       | `""`        | conditional |
| image_url                 | URL of the container image. Required if not creating a repository.                                              | `string`       | `""`        | conditional |
| [container_command]       | Command to run in the container. Defaults to the image's CMD.                                                   | `list(string)` | `[]`        | no          |
| container_port            | Port the container listens on.                                                                                  | `number`       | `80`        | no          |
| create_endpoint           | Create an Application Load Balancer for the service. Required to serve traffic.                                 | `bool`         | `true`      | no          |
| create_repository         | Create an ECR repository to host the container image.                                                           | `bool`         | `true`      | no          |
| create_version_parameter  | Create an SSM parameter to store the active version for the image tag.                                          | `bool`         | `false`     | no          |
| cpu                       | CPU unit for this task.                                                                                         | `number`       | `512`       | no          |
| enable_execute_command    | Enable the [ECS ExecuteCommand][ecs-exec] feature.                                                              | `bool`         | `false`     | no          |
| environment               | Environment for the project.                                                                                    | `string`       | `"dev"`     | no          |
| [environment_secrets]     | Secrets to be injected as environment variables into the container.                                             | `map(string)`  | `{}`        | no          |
| environment_variables     | Environment variables to be set on the container.                                                               | `map(string)`  | `{}`        | no          |
| execution_policies        | Additional policies for the task execution role.                                                                | `list(string)` | `[]`        | no          |
| force_delete              | Force deletion of resources. If changing to true, be sure to apply before destroying.                           | `bool`         | `false`     | no          |
| health_check_grace_period | Time, in seconds, after a container comes into service before health checks must pass.                          | `number`       | `300`       | no          |
| health_check_path         | Application path to use for health checks.                                                                      | `string`       | `"/health"` | no          |
| image_tag                 | Tag of the container image to be deployed.                                                                      | `string`       | `"latest"`  | no          |
| image_tags_mutable        | Whether the container repository allows tags to be mutated.                                                     | `bool`         | `false`     | no          |
| ingress_cidrs             | List of additional CIDR blocks to allow traffic from.                                                           | `list`         | `[]`        | no          |
| key_recovery_period       | Number of days to recover the service KMS key after deletion.                                                   | `number`       | `30`        | no          |
| log_retention_period      | Retention period for flow logs, in days.                                                                        | `number`       | `30`        | no          |
| memory                    | Memory for this task.                                                                                           | `number`       | `1024`      | no          |
| otel_log_level            | Log level for the OpenTelemetry collector.                                                                      | `string`       | `"info"`    | no          |
| public                    | Whether the service should be exposed to the public Internet.                                                   | `bool`         | `false`     | no          |
| repository_arn            | ARN of the ECR repository hosting the image. Only required if using a private repository, but not created here. | `string`       | `""`        | no          |
| [secrets_manager_secrets] | Map of secrets to be created in Secrets Manager.                                                                | `map(object)`  | `{}`        | no          |
| stats_prefix              | Prefix for statsd metrics. Defaults to `project`/`service`.                                                     | `string`       | `""`        | no          |
| subdomain                 | Optional subdomain for the service, to be appended to the domain for DNS.                                       | `string`       | `""`        | no          |
| tags                      | Optional tags to be applied to all resources.                                                                   | `list`         | `[]`        | no          |
| task_policies             | Additional policies for the task role.                                                                          | `list(string)` | `[]`        | no          |
| untagged_image_retention  | Retention period (after push) for untagged images, in days.                                                     | `number`       | `14`        | no          |
| version_parameter         | Optional SSM parameter to use for the image tag.                                                                | `string`       | `null`      | no          |

### container_command

In order to override the command that the container runs, you can provide a list
of strings to be passed to the container. For example, to run a container that
starts rack, you could use:

```hcl
container_command = ["bundle", "exec", "rackup"]
```

### environment_secrets

An optional map of secrets to be injected as environment variables into the
container. The key is the name of the environment variable, and the value is the
identifier and key of a secret, seperated by ":". The identifier may be the name
of a secret defined using [secrets_manager_secrets], or the full ARN of an
existing secret. For example:

```hcl
environment_secrets = {
  EXAMPLE_CLIENT_ID  = "client:client_id"
  EXAMPLE_CLIENT_KEY = "arn:aws:secretsmanager:us-east-1:123456789012:secret:project/staging/client:key"
}
```

### secrets_manager_secrets

> [!CAUTION]
> This feature may be removed in a future version. It is recommended to use the
> [secrets] module to manage secrets instead.

An optional map of secrets to be created in [AWS Secrets
Manager][secrets-manager]. Once the secret is created, any changes to the value
will be ignored. For example, to create a secret named `example`:

```hcl
secrets_manager_secrets = {
  example = {
    recovery_window = 7
    description     = "Example credentials for our application."
  }
}
```

| Name                   | Description                                                  | Type     | Default | Required |
|------------------------|--------------------------------------------------------------|----------|---------|----------|
| description            | Description of the secret.                                   | `string` | n/a     | yes      |
| recovery_window        | Number of days that a secret can be recovered after deltion. | `string` | `30`    | no       |
| create_random_password | Creates a random password as the staring value.              | `bool`   | `false` | no       |
| start_value            | Value to be set into the secret at creation.                 | `string` | `"{}"`  | no       |

## Outputs

| Name                       | Description                                                             | Type     |
|----------------------------|-------------------------------------------------------------------------|----------|
| cluster_name               | Name of the ECS Fargate cluster.                                        | `string` |
| docker_push                | Commands to push a Docker image to the container repository.            | `string` |
| endpoint_security_group_id | Security group ID for the endpoint.                                     | `string` |
| repository_arn             | ARN of the ECR repository, if created.                                  | `string` |
| repository_url             | URL for the container image repository.                                 | `string` |
| security_group_id          | Security group ID for the service.                                      | `string` |
| version_parameter          | Name of the SSM parameter, if one exists, to store the current version. | `string` |

[badge-checks]: https://github.com/codeforamerica/tofu-modules-aws-fargate-service/actions/workflows/main.yaml/badge.svg

[badge-release]: https://img.shields.io/github/v/release/codeforamerica/tofu-modules-aws-fargate-service?logo=github&label=Latest%20Release

[code-checks]: https://github.com/codeforamerica/tofu-modules-aws-fargate-service/actions/workflows/main.yaml

[container_command]: #container_command

[ecs-exec]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html

[environment_secrets]: #environment_secrets

[latest-release]: https://github.com/codeforamerica/tofu-modules-aws-fargate-service/releases/latest

[secrets]: https://github.com/codeforamerica/tofu-modules-aws-secrets

[secrets-manager]: https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html

[secrets_manager_secrets]: #secrets_manager_secrets

[tofu-modules]: https://github.com/codeforamerica/tofu-modules
