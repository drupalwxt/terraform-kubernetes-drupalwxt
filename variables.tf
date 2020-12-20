
variable "chart_version" {}

variable "dependencies" {
  type = "list"
}

variable "helm_namespace" {}

variable "helm_repository" {}

variable "values" {
  default = ""
  type    = "string"
}
