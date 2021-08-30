
variable "chart_version" {}

variable "helm_chart" {}

variable "helm_name" {
  default = "drupalwxt"
  type    = string
}

variable "helm_namespace" {}

variable "helm_repository" {}

variable "values" {
  default = ""
  type    = string
}
