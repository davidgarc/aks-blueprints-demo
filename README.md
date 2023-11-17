# terraform-azurerm-aks-blueprints-demo

Example project that showcases how to leverage [Amazon EKS Blueprint for Terraform](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main) patterns in Azure Kubernetes Service (AKS).

## Project structure

This projects has a the following set of local modules for the purpose of this demo:

- `aks-cluster` - Azure Kubernetes Service (AKS) cluster module
- `aks-blueprint-addon` - Blueprint Addon for installing a module in the cluster through the helm provider
- `aks-blueprint-addons` - Blueprint Addons with a curated collection of addons to be installed in the cluster

## Next Steps

- [ ] Cleanup the projects of all AWS related resources
- [ ] Add support for Azure AD integration and workload identity for addons that require it
- [ ] Add support for Azure AKS extensions
- [ ] Remove built in aks module and use the official one
- [ ] add example folder with multiple patterns like they do in the Amazon EKS blueprint project
