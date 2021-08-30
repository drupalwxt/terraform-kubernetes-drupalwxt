resource "helm_release" "drupalwxt" {
  version = var.chart_version

  name  = var.helm_name
  chart = var.helm_chart

  repository = var.helm_repository
  namespace  = var.helm_namespace

  timeout = 2400

  values = [
    "${var.values}",
  ]
}
