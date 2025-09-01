variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región de GCP"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona de GCP"
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "Nombre del cluster GKE"
  type        = string
  default     = "my-gke-cluster"
}

variable "node_count" {
  description = "Número inicial de nodos"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Tipo de máquina para nodos"
  type        = string
  default     = "e2-medium"
}

variable "enable_autopilot" {
  description = "Habilitar modo Autopilot"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = "1.28.0"
}

variable "enable_network_policy" {
  description = "Habilitar network policies"
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Habilitar Binary Authorization"
  type        = bool
  default     = false
}