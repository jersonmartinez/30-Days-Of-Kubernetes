output "resource_group_name" {
  description = "Nombre del Resource Group"
  value       = azurerm_resource_group.aks.name
}

output "cluster_name" {
  description = "Nombre del cluster AKS"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_id" {
  description = "ID del cluster AKS"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "kube_config" {
  description = "Configuración de kubectl"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "client_key" {
  description = "Client key para kubectl"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate para kubectl"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate del cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "host" {
  description = "Endpoint del cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
}

output "acr_login_server" {
  description = "Login server del ACR"
  value       = azurerm_container_registry.aks.login_server
}

output "acr_admin_username" {
  description = "Username del ACR"
  value       = azurerm_container_registry.aks.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Password del ACR"
  value       = azurerm_container_registry.aks.admin_password
  sensitive   = true
}