# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.7.0 (2025-11-14)

### Feat

- Allow prefix lists to be used for ingress. (#34)

## 1.6.2 (2025-10-08)

### Fix

- Added Load Balancer ARN to outputs. (#32)

## 1.6.1 (2025-08-18)

### Fix

- String secrets don't work because we assume there's a JSON key in the ARN. (#30)

## 1.6.0 (2025-08-15)

### Feat

- Optionally prefix the target group name with the port.  (#28)

## 1.5.1 (2025-08-05)

### Fix

- Mark OIDC settings as non-sensitive when using safe portions for keys. (#26)

## 1.5.0 (2025-06-25)

### Feat

- Added persistent volume configuration. (#24)

## 1.4.0 (2025-06-24)

### Feat

- Added log exports for the load balancer. (#23)
- Support OIDC connections on the endpoint. (#20)

## 1.3.0 (2025-06-14)

### Feat

- Make task resources configurable. (#16)
- Allow the desired number of containers to be configured. (#19)
- Added security group outputs. (#17)

## 1.2.1 (2025-05-09)

### Fix

- Output for `repository_url` when not creating a repository. (#14)

## 1.2.0 (2025-04-22)

### Feat

- Add support for SSM version parameter. (#8)
- Make IAM policies extendable. (#10)

## 1.1.0 (2025-04-17)

### Feat

- Allow health check endpoint and grace period to be customized. (CCAP-690) (#4)

## 1.0.0 (2024-12-05)

### Feat

- Initial release. (#1)
