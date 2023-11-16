variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the cluster OIDC Provider"
  type        = string
}

variable "create_delay_duration" {
  description = "The duration to wait before creating resources"
  type        = string
  default     = "30s"
}

variable "create_delay_dependencies" {
  description = "Dependency attribute which must be resolved before starting the `create_delay_duration`"
  type        = list(string)
  default     = []
}

################################################################################
# (Generic) Helm Release
################################################################################

variable "helm_releases" {
  description = "A map of Helm releases to create. This provides the ability to pass in an arbitrary map of Helm chart definitions to create"
  type        = any
  default     = {}
}

################################################################################
# ArgoCD
################################################################################

variable "enable_argocd" {
  description = "Enable Argo CD Kubernetes add-on"
  type        = bool
  default     = false
}

variable "argocd" {
  description = "ArgoCD add-on configuration values"
  type        = any
  default     = {}
}

################################################################################
# Cert Manager
################################################################################

variable "enable_cert_manager" {
  description = "Enable cert-manager add-on"
  type        = bool
  default     = false
}

variable "cert_manager" {
  description = "cert-manager add-on configuration values"
  type        = any
  default     = {}
}

################################################################################
# External Secrets
################################################################################

variable "enable_external_secrets" {
  description = "Enable External Secrets operator add-on"
  type        = bool
  default     = false
}

variable "external_secrets" {
  description = "External Secrets add-on configuration values"
  type        = any
  default     = {}
}

variable "external_secrets_ssm_parameter_arns" {
  description = "List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:ssm:*:*:parameter/*"]
}

variable "external_secrets_secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
}

variable "external_secrets_kms_key_arns" {
  description = "List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:kms:*:*:key/*"]
}

################################################################################
# Ingress Nginx
################################################################################

variable "enable_ingress_nginx" {
  description = "Enable Ingress Nginx"
  type        = bool
  default     = false
}

variable "ingress_nginx" {
  description = "Ingress Nginx add-on configurations"
  type        = any
  default     = {}
}

################################################################################
# Velero
################################################################################

variable "enable_velero" {
  description = "Enable Kubernetes Dashboard add-on"
  type        = bool
  default     = false
}

variable "velero" {
  description = "Velero add-on configuration values"
  type        = any
  default     = {}
}

################################################################################
# GitOps Bridge
################################################################################

variable "create_kubernetes_resources" {
  description = "Create Kubernetes resource with Helm or Kubernetes provider"
  type        = bool
  default     = true
}
