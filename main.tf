provider "azurerm" {
  features {}
}

locals {
  cluster_name = "aks-cluster"
  region       = "southcentralus"
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
  load_config_file       = false
}

################################################################################
# Cluster
################################################################################

module "aks-cluster" {
  source = "./modules/aks-cluster"

  cluster_name = local.cluster_name
  location     = local.region
}

data "azurerm_kubernetes_cluster" "default" {
  depends_on          = [module.aks-cluster] # refresh cluster state before reading
  name                = local.cluster_name
  resource_group_name = local.cluster_name
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source = "./modules/aks-blueprint-addons"

  cluster_name      = local.cluster_name
  cluster_endpoint  = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  cluster_version   = data.azurerm_kubernetes_cluster.default.kubernetes_version
  oidc_provider_arn = data.azurerm_kubernetes_cluster.default.oidc_issuer_url

  # Add-ons
  enable_ingress_nginx = true
  ingress_nginx = {
    controller = {
      replicaCount = 2
      name         = "demo-controller"
    }
  }
}
