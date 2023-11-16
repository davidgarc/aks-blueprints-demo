
# This resource is used to provide a means of mapping an implicit dependency
# between the cluster and the addons.
resource "time_sleep" "this" {
  create_duration = var.create_delay_duration

  triggers = {
    cluster_endpoint  = var.cluster_endpoint
    cluster_name      = var.cluster_name
    custom            = join(",", var.create_delay_dependencies)
    oidc_provider_arn = var.oidc_provider_arn
  }
}

locals {

  # Threads the sleep resource into the module to make the dependency
  cluster_endpoint  = time_sleep.this.triggers["cluster_endpoint"]
  cluster_name      = time_sleep.this.triggers["cluster_name"]
  oidc_provider_arn = time_sleep.this.triggers["oidc_provider_arn"]

}

################################################################################
# ArgoCD
################################################################################

module "argocd" {
  source = "../aks-blueprint-addon"

  create = var.enable_argocd

  # Disable helm release
  create_release = var.create_kubernetes_resources

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/Chart.yaml
  # (there is no official helm chart for argocd)
  name             = try(var.argocd.name, "argo-cd")
  description      = try(var.argocd.description, "A Helm chart to install the ArgoCD")
  namespace        = try(var.argocd.namespace, "argocd")
  create_namespace = try(var.argocd.create_namespace, true)
  chart            = try(var.argocd.chart, "argo-cd")
  chart_version    = try(var.argocd.chart_version, "5.42.1")
  repository       = try(var.argocd.repository, "https://argoproj.github.io/argo-helm")
  values           = try(var.argocd.values, [])

  timeout                    = try(var.argocd.timeout, null)
  repository_key_file        = try(var.argocd.repository_key_file, null)
  repository_cert_file       = try(var.argocd.repository_cert_file, null)
  repository_ca_file         = try(var.argocd.repository_ca_file, null)
  repository_username        = try(var.argocd.repository_username, null)
  repository_password        = try(var.argocd.repository_password, null)
  devel                      = try(var.argocd.devel, null)
  verify                     = try(var.argocd.verify, null)
  keyring                    = try(var.argocd.keyring, null)
  disable_webhooks           = try(var.argocd.disable_webhooks, null)
  reuse_values               = try(var.argocd.reuse_values, null)
  reset_values               = try(var.argocd.reset_values, null)
  force_update               = try(var.argocd.force_update, null)
  recreate_pods              = try(var.argocd.recreate_pods, null)
  cleanup_on_fail            = try(var.argocd.cleanup_on_fail, null)
  max_history                = try(var.argocd.max_history, null)
  atomic                     = try(var.argocd.atomic, null)
  skip_crds                  = try(var.argocd.skip_crds, null)
  render_subchart_notes      = try(var.argocd.render_subchart_notes, null)
  disable_openapi_validation = try(var.argocd.disable_openapi_validation, null)
  wait                       = try(var.argocd.wait, false)
  wait_for_jobs              = try(var.argocd.wait_for_jobs, null)
  dependency_update          = try(var.argocd.dependency_update, null)
  replace                    = try(var.argocd.replace, null)
  lint                       = try(var.argocd.lint, null)

  postrender    = try(var.argocd.postrender, [])
  set           = try(var.argocd.set, [])
  set_sensitive = try(var.argocd.set_sensitive, [])

  tags = var.tags
}

################################################################################
# Cert Manager
################################################################################

locals {
  cert_manager_namespace = try(var.cert_manager.namespace, "cert-manager")
}

module "cert_manager" {
  source = "../aks-blueprint-addon"

  create = var.enable_cert_manager

  # Disable helm release
  create_release = var.create_kubernetes_resources

  # https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/Chart.template.yaml
  name             = try(var.cert_manager.name, "cert-manager")
  description      = try(var.cert_manager.description, "A Helm chart to deploy cert-manager")
  namespace        = local.cert_manager_namespace
  create_namespace = try(var.cert_manager.create_namespace, true)
  chart            = try(var.cert_manager.chart, "cert-manager")
  chart_version    = try(var.cert_manager.chart_version, "v1.12.3")
  repository       = try(var.cert_manager.repository, "https://charts.jetstack.io")
  values           = try(var.cert_manager.values, [])

  timeout                    = try(var.cert_manager.timeout, null)
  repository_key_file        = try(var.cert_manager.repository_key_file, null)
  repository_cert_file       = try(var.cert_manager.repository_cert_file, null)
  repository_ca_file         = try(var.cert_manager.repository_ca_file, null)
  repository_username        = try(var.cert_manager.repository_username, null)
  repository_password        = try(var.cert_manager.repository_password, null)
  devel                      = try(var.cert_manager.devel, null)
  verify                     = try(var.cert_manager.verify, null)
  keyring                    = try(var.cert_manager.keyring, null)
  disable_webhooks           = try(var.cert_manager.disable_webhooks, null)
  reuse_values               = try(var.cert_manager.reuse_values, null)
  reset_values               = try(var.cert_manager.reset_values, null)
  force_update               = try(var.cert_manager.force_update, null)
  recreate_pods              = try(var.cert_manager.recreate_pods, null)
  cleanup_on_fail            = try(var.cert_manager.cleanup_on_fail, null)
  max_history                = try(var.cert_manager.max_history, null)
  atomic                     = try(var.cert_manager.atomic, null)
  skip_crds                  = try(var.cert_manager.skip_crds, null)
  render_subchart_notes      = try(var.cert_manager.render_subchart_notes, null)
  disable_openapi_validation = try(var.cert_manager.disable_openapi_validation, null)
  wait                       = try(var.cert_manager.wait, false)
  wait_for_jobs              = try(var.cert_manager.wait_for_jobs, null)
  dependency_update          = try(var.cert_manager.dependency_update, null)
  replace                    = try(var.cert_manager.replace, null)
  lint                       = try(var.cert_manager.lint, null)

  postrender = try(var.cert_manager.postrender, [])
  set = concat([
    {
      name  = "installCRDs"
      value = true
    }
    ],
    try(var.cert_manager.set, [])
  )
  set_sensitive = try(var.cert_manager.set_sensitive, [])

  tags = var.tags
}

################################################################################
# External Secrets
################################################################################

locals {
  external_secrets_service_account = try(var.external_secrets.service_account_name, "external-secrets-sa")
  external_secrets_namespace       = try(var.external_secrets.namespace, "external-secrets")
}

module "external_secrets" {
  source = "../aks-blueprint-addon"

  create = var.enable_external_secrets

  # Disable helm release
  create_release = var.create_kubernetes_resources

  # https://github.com/external-secrets/external-secrets/blob/main/deploy/charts/external-secrets/Chart.yaml
  name             = try(var.external_secrets.name, "external-secrets")
  description      = try(var.external_secrets.description, "A Helm chart to deploy external-secrets")
  namespace        = local.external_secrets_namespace
  create_namespace = try(var.external_secrets.create_namespace, true)
  chart            = try(var.external_secrets.chart, "external-secrets")
  chart_version    = try(var.external_secrets.chart_version, "0.9.1")
  repository       = try(var.external_secrets.repository, "https://charts.external-secrets.io")
  values           = try(var.external_secrets.values, [])

  timeout                    = try(var.external_secrets.timeout, null)
  repository_key_file        = try(var.external_secrets.repository_key_file, null)
  repository_cert_file       = try(var.external_secrets.repository_cert_file, null)
  repository_ca_file         = try(var.external_secrets.repository_ca_file, null)
  repository_username        = try(var.external_secrets.repository_username, null)
  repository_password        = try(var.external_secrets.repository_password, null)
  devel                      = try(var.external_secrets.devel, null)
  verify                     = try(var.external_secrets.verify, null)
  keyring                    = try(var.external_secrets.keyring, null)
  disable_webhooks           = try(var.external_secrets.disable_webhooks, null)
  reuse_values               = try(var.external_secrets.reuse_values, null)
  reset_values               = try(var.external_secrets.reset_values, null)
  force_update               = try(var.external_secrets.force_update, null)
  recreate_pods              = try(var.external_secrets.recreate_pods, null)
  cleanup_on_fail            = try(var.external_secrets.cleanup_on_fail, null)
  max_history                = try(var.external_secrets.max_history, null)
  atomic                     = try(var.external_secrets.atomic, null)
  skip_crds                  = try(var.external_secrets.skip_crds, null)
  render_subchart_notes      = try(var.external_secrets.render_subchart_notes, null)
  disable_openapi_validation = try(var.external_secrets.disable_openapi_validation, null)
  wait                       = try(var.external_secrets.wait, false)
  wait_for_jobs              = try(var.external_secrets.wait_for_jobs, null)
  dependency_update          = try(var.external_secrets.dependency_update, null)
  replace                    = try(var.external_secrets.replace, null)
  lint                       = try(var.external_secrets.lint, null)

  postrender = try(var.external_secrets.postrender, [])
  set = concat([
    {
      name  = "serviceAccount.name"
      value = local.external_secrets_service_account
    }],
    try(var.external_secrets.set, [])
  )
  set_sensitive = try(var.external_secrets.set_sensitive, [])

  tags = var.tags
}

################################################################################
# Ingress Nginx
################################################################################

module "ingress_nginx" {
  source = "../aks-blueprint-addon"

  create = var.enable_ingress_nginx

  # Disable helm release
  create_release = var.create_kubernetes_resources

  # https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/Chart.yaml
  name             = try(var.ingress_nginx.name, "ingress-nginx")
  description      = try(var.ingress_nginx.description, "A Helm chart to install the Ingress Nginx")
  namespace        = try(var.ingress_nginx.namespace, "ingress-nginx")
  create_namespace = try(var.ingress_nginx.create_namespace, true)
  chart            = try(var.ingress_nginx.chart, "ingress-nginx")
  chart_version    = try(var.ingress_nginx.chart_version, "4.7.1")
  repository       = try(var.ingress_nginx.repository, "https://kubernetes.github.io/ingress-nginx")
  values           = try(var.ingress_nginx.values, [])

  timeout                    = try(var.ingress_nginx.timeout, null)
  repository_key_file        = try(var.ingress_nginx.repository_key_file, null)
  repository_cert_file       = try(var.ingress_nginx.repository_cert_file, null)
  repository_ca_file         = try(var.ingress_nginx.repository_ca_file, null)
  repository_username        = try(var.ingress_nginx.repository_username, null)
  repository_password        = try(var.ingress_nginx.repository_password, null)
  devel                      = try(var.ingress_nginx.devel, null)
  verify                     = try(var.ingress_nginx.verify, null)
  keyring                    = try(var.ingress_nginx.keyring, null)
  disable_webhooks           = try(var.ingress_nginx.disable_webhooks, null)
  reuse_values               = try(var.ingress_nginx.reuse_values, null)
  reset_values               = try(var.ingress_nginx.reset_values, null)
  force_update               = try(var.ingress_nginx.force_update, null)
  recreate_pods              = try(var.ingress_nginx.recreate_pods, null)
  cleanup_on_fail            = try(var.ingress_nginx.cleanup_on_fail, null)
  max_history                = try(var.ingress_nginx.max_history, null)
  atomic                     = try(var.ingress_nginx.atomic, null)
  skip_crds                  = try(var.ingress_nginx.skip_crds, null)
  render_subchart_notes      = try(var.ingress_nginx.render_subchart_notes, null)
  disable_openapi_validation = try(var.ingress_nginx.disable_openapi_validation, null)
  wait                       = try(var.ingress_nginx.wait, false)
  wait_for_jobs              = try(var.ingress_nginx.wait_for_jobs, null)
  dependency_update          = try(var.ingress_nginx.dependency_update, null)
  replace                    = try(var.ingress_nginx.replace, null)
  lint                       = try(var.ingress_nginx.lint, null)

  postrender    = try(var.ingress_nginx.postrender, [])
  set           = try(var.ingress_nginx.set, [])
  set_sensitive = try(var.ingress_nginx.set_sensitive, [])

  tags = var.tags
}



################################################################################
# Velero
################################################################################

locals {
  velero_name                    = "velero"
  velero_service_account         = try(var.velero.service_account_name, "${local.velero_name}-server")
  velero_backup_s3_bucket        = try(split(":", var.velero.s3_backup_location), [])
  velero_backup_s3_bucket_arn    = try(split("/", var.velero.s3_backup_location)[0], var.velero.s3_backup_location, "")
  velero_backup_s3_bucket_name   = try(split("/", local.velero_backup_s3_bucket[5])[0], local.velero_backup_s3_bucket[5], "")
  velero_backup_s3_bucket_prefix = try(split("/", var.velero.s3_backup_location)[1], "")
  velero_namespace               = try(var.velero.namespace, "velero")
}

# https://github.com/vmware-tanzu/velero-plugin-for-aws#option-1-set-permissions-with-an-iam-user
# data "aws_iam_policy_document" "velero" {
#   count = var.enable_velero ? 1 : 0

#   source_policy_documents   = lookup(var.velero, "source_policy_documents", [])
#   override_policy_documents = lookup(var.velero, "override_policy_documents", [])

#   statement {
#     actions = [
#       "ec2:CreateSnapshot",
#       "ec2:CreateSnapshots",
#       "ec2:CreateTags",
#       "ec2:CreateVolume",
#       "ec2:DeleteSnapshot"
#     ]
#     resources = [
#       "arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/*",
#       "arn:${local.partition}:ec2:${local.region}::snapshot/*",
#       "arn:${local.partition}:ec2:${local.region}:${local.account_id}:volume/*"
#     ]
#   }

#   statement {
#     actions = [
#       "ec2:DescribeSnapshots",
#       "ec2:DescribeVolumes"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     actions = [
#       "s3:AbortMultipartUpload",
#       "s3:DeleteObject",
#       "s3:GetObject",
#       "s3:ListMultipartUploadParts",
#       "s3:PutObject",
#     ]
#     resources = ["${var.velero.s3_backup_location}/*"]
#   }

#   statement {
#     actions   = ["s3:ListBucket"]
#     resources = [local.velero_backup_s3_bucket_arn]
#   }
# }

module "velero" {
  source = "../aks-blueprint-addon"

  create = var.enable_velero

  # Disable helm release
  create_release = var.create_kubernetes_resources

  # https://github.com/vmware-tanzu/helm-charts/blob/main/charts/velero/Chart.yaml
  name             = try(var.velero.name, "velero")
  description      = try(var.velero.description, "A Helm chart to install the Velero")
  namespace        = local.velero_namespace
  create_namespace = try(var.velero.create_namespace, true)
  chart            = try(var.velero.chart, "velero")
  chart_version    = try(var.velero.chart_version, "3.2.0") # TODO - 4.0.0 is out
  repository       = try(var.velero.repository, "https://vmware-tanzu.github.io/helm-charts/")
  values           = try(var.velero.values, [])

  timeout                    = try(var.velero.timeout, null)
  repository_key_file        = try(var.velero.repository_key_file, null)
  repository_cert_file       = try(var.velero.repository_cert_file, null)
  repository_ca_file         = try(var.velero.repository_ca_file, null)
  repository_username        = try(var.velero.repository_username, null)
  repository_password        = try(var.velero.repository_password, null)
  devel                      = try(var.velero.devel, null)
  verify                     = try(var.velero.verify, null)
  keyring                    = try(var.velero.keyring, null)
  disable_webhooks           = try(var.velero.disable_webhooks, null)
  reuse_values               = try(var.velero.reuse_values, null)
  reset_values               = try(var.velero.reset_values, null)
  force_update               = try(var.velero.force_update, null)
  recreate_pods              = try(var.velero.recreate_pods, null)
  cleanup_on_fail            = try(var.velero.cleanup_on_fail, null)
  max_history                = try(var.velero.max_history, null)
  atomic                     = try(var.velero.atomic, null)
  skip_crds                  = try(var.velero.skip_crds, null)
  render_subchart_notes      = try(var.velero.render_subchart_notes, null)
  disable_openapi_validation = try(var.velero.disable_openapi_validation, null)
  wait                       = try(var.velero.wait, false)
  wait_for_jobs              = try(var.velero.wait_for_jobs, null)
  dependency_update          = try(var.velero.dependency_update, null)
  replace                    = try(var.velero.replace, null)
  lint                       = try(var.velero.lint, null)

  postrender = try(var.velero.postrender, [])
  set = concat([
    {
      name  = "initContainers"
      value = <<-EOT
        - name: velero-plugin-for-aws
          image: velero/velero-plugin-for-aws:v1.7.1
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - mountPath: /target
              name: plugins
      EOT
    },
    {
      name  = "serviceAccount.server.name"
      value = local.velero_service_account
    },
    {
      name  = "configuration.provider"
      value = "aws"
    },
    {
      name  = "configuration.backupStorageLocation.prefix"
      value = local.velero_backup_s3_bucket_prefix
    },
    {
      name  = "configuration.backupStorageLocation.bucket"
      value = local.velero_backup_s3_bucket_name
    },
    # {
    #   name  = "configuration.backupStorageLocation.config.region"
    #   value = local.region
    # },
    # {
    #   name  = "configuration.volumeSnapshotLocation.config.region"
    #   value = local.region
    # },
    {
      name  = "credentials.useSecret"
      value = false
    }],
    try(var.velero.set, [])
  )
  set_sensitive = try(var.velero.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names = ["serviceAccount.server.annotations.eks\\.amazonaws\\.com/role-arn"]
  # create_role                   = try(var.velero.create_role, true)
  # role_name                     = try(var.velero.role_name, "velero")
  # role_name_use_prefix          = try(var.velero.role_name_use_prefix, true)
  # role_path                     = try(var.velero.role_path, "/")
  # role_permissions_boundary_arn = lookup(var.velero, "role_permissions_boundary_arn", null)
  # role_description              = try(var.velero.role_description, "IRSA for Velero")
  # role_policies                 = lookup(var.velero, "role_policies", {})

  # source_policy_documents = data.aws_iam_policy_document.velero[*].json
  # policy_statements       = lookup(var.velero, "policy_statements", [])
  # policy_name             = try(var.velero.policy_name, "velero")
  # policy_name_use_prefix  = try(var.velero.policy_name_use_prefix, true)
  # policy_path             = try(var.velero.policy_path, null)
  # policy_description      = try(var.velero.policy_description, "IAM Policy for Velero")

  # oidc_providers = {
  #   controller = {
  #     provider_arn = local.oidc_provider_arn
  #     # namespace is inherited from chart
  #     service_account = local.velero_service_account
  #   }
  # }

  tags = var.tags
}
