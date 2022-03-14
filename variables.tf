variable "namespace" {
  description = "Namespace for monitoring deployment containing pod runtime"
  type        = string
}

variable "docker_tag" {
  description = "Tag of image ackee/gke_oom_monitoring used for monitoring"
  default     = "latest"
  type        = string
}

variable "project" {
  description = "Project ID"
  type        = string
}

variable "location" {
  description = "Location of the monitored pods"
  type        = string
}

variable "cluster_name" {
  description = "Name of cluster of the monitored pods"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Public CA certificate that is the root of trust for the GKE K8s cluster"
  type        = string
}

variable "cluster_token" {
  description = "Cluster master token, keep always secret!"
  type        = string
}

variable "cluster_endpoint" {
  description = "Cluster control plane endpoint"
  type        = string
}

variable "include_dashboard" {
  description = "Include dashboard as k8s secret"
  default     = true
}
