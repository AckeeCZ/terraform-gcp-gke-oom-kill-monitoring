resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

resource "google_service_account" "sa" {
  account_id   = "gke-oom-monitoring-${random_string.random.result}"
  display_name = "gke-oom-monitoring-${random_string.random.result}"
}

resource "kubernetes_service_account" "sa" {
  metadata {
    namespace = var.namespace
    name      = "gke-oom-monitoring-${random_string.random.result}"
    annotations = {
      "iam.gke.io/gcp-service-account" : google_service_account.sa.email
    }
  }
}

resource "google_service_account_iam_member" "sa_allow_iam_workload_identity" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[${var.namespace}/gke-oom-monitoring-${random_string.random.result}]"
}

resource "google_project_iam_member" "sa" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "kubernetes_role" "sa" {
  metadata {
    namespace = var.namespace
    name      = "gke-oom-monitoring-${random_string.random.result}"
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "sa" {
  metadata {
    name      = "gke-oom-monitoring-${random_string.random.result}"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.sa.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "gke-oom-monitoring-${random_string.random.result}"
    namespace = var.namespace
  }
}
