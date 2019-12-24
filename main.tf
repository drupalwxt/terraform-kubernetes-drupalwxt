# Part of a hack for module-to-module dependencies.
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
# and
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-473091030
# Make sure to add this null_resource.dependency_getter to the `depends_on`
# attribute to all resource(s) that will be constructed first within this
# module:
resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = "${join(",", var.dependencies)}"
  }

  lifecycle {
    ignore_changes = [
      triggers["my_dependencies"],
    ]
  }
}

resource "null_resource" "wait-dependencies" {
  provisioner "local-exec" {
    command = "helm ls --tiller-namespace ${var.helm_namespace}"
  }

  depends_on = [
    "null_resource.dependency_getter",
  ]
}

resource "local_file" "storageclass_azurefile" {
  content = "${templatefile("${path.module}/config/azurefile.yaml", {
    azurefile_location_name        = "${var.azurefile_location_name}"
    azurefile_storage_account_name = "${var.azurefile_storage_account_name}"
  })}"

  filename = "${path.module}/generated/azurefile.yaml"
}

resource "null_resource" "storageclass_azurefile" {
  count = "${var.enable_azurefile ? 1 : 0}"

  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.storageclass_azurefile.filename}"
  }
}

resource "helm_release" "drupalwxt" {
  version    = "${var.chart_version}"
  name       = "drupalwxt"
  chart      = "drupal"
  repository = "${var.helm_repository}"
  namespace  = "${var.helm_namespace}"

  timeout = 2400

  values = [
    "${var.values}",
  ]

  depends_on = [
    "null_resource.wait-dependencies",
    "null_resource.dependency_getter",
    "null_resource.storageclass_azurefile"
  ]
}

# Part of a hack for module-to-module dependencies.
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
resource "null_resource" "dependency_setter" {
  # Part of a hack for module-to-module dependencies.
  # https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
  # List resource(s) that will be constructed last within the module.
  depends_on = [
    "helm_release.drupalwxt"
  ]
}
