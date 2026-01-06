output "cluster_name" {
  description = "Name of the ECS Fargate cluster."
  value       = module.ecs.name
}

output "docker_push" {
  description = "Commands to push a Docker image to the container repository."
  value       = !var.create_repository ? "" : <<EOT
aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${module.ecr["this"].repository_registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com
docker build -t ${module.ecr["this"].repository_name} --platform linux/amd64 .
docker tag ${module.ecr["this"].repository_name}:${var.image_tag} ${local.image_url}:latest
docker push ${local.image_url}:latest
EOT
}

output "endpoint_security_group_id" {
  description = "Security group ID for the endpoint."
  value       = module.endpoint_security_group.security_group_id
}

output "endpoint_url" {
  description = "URL of the service endpoint."
  value       = var.create_endpoint ? aws_route53_record.endpoint["this"].fqdn : ""
}

output "load_balancer_arn" {
  description = "ARN of the load balancer, if created."
  value       = var.create_endpoint ? module.alb["this"].arn : ""
}

output "log_groups" {
  description = "CloudWatch log groups created for the service."
  value       = aws_cloudwatch_log_group.this
}

output "repository_arn" {
  description = "ARN of the ECR repository, if created."
  value       = local.repository_arn
}

output "repository_url" {
  description = "URL of the container image repository."
  value       = local.image_url
}

output "security_group_id" {
  description = "Security group ID for the service."
  value       = module.task_security_group.security_group_id
}

output "version_parameter" {
  description = "Name of the SSM parameter, if one exists, to store the current version."
  value       = local.version_parameter
}
