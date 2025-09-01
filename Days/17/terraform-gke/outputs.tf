output "cluster_name" {
  description = "Nombre del cluster GKE"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Endpoint del cluster"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "Certificado CA del cluster"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "kubectl_command" {
  description = "Comando para conectar kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${var.project_id}"
}

output "vpc_network" {
  description = "Nombre de la VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Nombre de la subred"
  value       = google_compute_subnetwork.subnet.name
}

output "service_account_email" {
  description = "Email del service account creado"
  value       = google_service_account.gke_sa.email
}

output "backup_bucket_name" {
  description = "Nombre del bucket de backups"
  value       = google_storage_bucket.backup_bucket.name
}

output "cluster_location" {
  description = "Ubicación del cluster (zona o región)"
  value       = google_container_cluster.primary.location
}

output "kubernetes_version" {
  description = "Versión de Kubernetes del cluster"
  value       = google_container_cluster.primary.master_version
}