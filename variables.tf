variable "enable_azurefile" {
  default = "0"
  type    = "string"
}

variable "azurefile_location_name" {
  default = "canadacentral"
  type    = "string"
}

variable "azurefile_storage_account_name" {
  default = ""
  type = "string"
}

variable "helm_namespace" {}

variable "helm_repository" {}

variable "chart_version" {}

variable "dependencies" {
  type = "list"
}

variable "values" {
  default = ""
  type    = "string"
}
