resource "kubernetes_secret" "grafana_oom_kills" {
  count = var.include_dashboard ? 1 : 0

  metadata {
    name      = "grafana-oom-kills"
    namespace = var.namespace
    labels = {
      grafana_dashboard = "true"
    }
    annotations = {
      "grafana_folder" = "/tmp/dashboards/infra"
    }
  }

  data = {
    "oom_kills.json" = file("${path.module}/dashboard.json")
  }
}
