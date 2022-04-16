resource "kubernetes_deployment" "gke_oom_killed_monitoring" {
  metadata {
    name      = "gke-oom-monitoring-${random_string.random.result}"
    namespace = var.namespace
    labels = {
      app = "gke-oom-monitoring-${random_string.random.result}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gke-oom-monitoring-${random_string.random.result}"
      }
    }

    template {
      metadata {
        labels = {
          app = "gke-oom-monitoring-${random_string.random.result}"
        }
      }

      spec {
        service_account_name = "gke-oom-monitoring-${random_string.random.result}"
        container {
          image = "ackee/gke_oom_monitoring:${var.docker_tag}"
          name  = "gke-oom-monitoring-${random_string.random.result}"
          env {
            name  = "NAMESPACE"
            value = var.namespace
          }
          env {
            name  = "PROJECT_ID"
            value = var.project
          }
          env {
            name  = "LOCATION"
            value = var.location
          }
          env {
            name  = "CLUSTER_NAME"
            value = var.cluster_name
          }
        }
      }
    }
  }
}
