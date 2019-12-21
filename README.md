# Terraform Kubernetes DrupalWxT

## Introduction

This module deploys and configures Drupal WxT inside a Kubernetes Cluster.

## Security Controls

The following security controls can be met through configuration of this template:

* TBD

## Dependencies

* None

## Usage

```terraform
module "helm_drupalwxt" {
  source = "github.com/drupalwxt/terraform-kubernetes-drupalwxt?ref=20190909.1"

  chart_version = "0.1.12"
  dependencies = [
    "${module.namespace_default.depended_on}",
  ]

  helm_service_account = "tiller"
  helm_namespace = "drupal"
  helm_repository = "drupalwxt"

  values = <<EOF
ingress:
  enabled: true
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  path: /
  hosts:
    - drupalwxt.${var.ingress_domain}
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local

drupal:
  tag: latest

  # php-fpm healthcheck
  # Requires https://github.com/renatomefi/php-fpm-healthcheck in the container.
  # (note: official images do not contain this feature yet)
  healthcheck:
    enabled: true

  # Switch to canada.ca theme
  # Common options include: theme-wet-boew, theme-gcweb-legacy
  wxtTheme: theme-gcweb

  # Run the site install
  install: true

  # Run the default migrations
  migrate: true

  # Reconfigure the site
  reconfigure: true

nginx:
  # Set your cluster's DNS resolution service here
  resolver: 10.0.0.10

mysql:
  imageTag: 5.7.26

  mysqlPassword: SUPERsecureMYSQLpassword
  mysqlRootPassword: SUPERsecureMYSQLrootPASSWORD
  persistence:
    enabled: true

##
## MINIO-ONLY EXAMPLE
##
minio:
  persistence:
    enabled: true
  defaultBucket:
    enabled: true

##
## AZURE EXAMPLE
##
# files:
#   cname:
#     enabled: true
#     hostname: wxt.blob.core.windows.net

minio:
  clusterDomain: cluster.cumulonimbus.zacharyseguin.ca
  # Enable the Azure Gateway mode
  azuregateway:
    enabled: true

  # Access Key should be set to the Azure Storage Account name
  # Secret Key should be set to the Azure Storage Account access key
  accessKey: STORAGE_ACCOUNT_NAME
  secretKey: STORAGE_ACCOUNT_ACCESS_KEY

  # Disable creation of default bucket.
  # You should pre-create the bucket in Azure.
  defaultBucket:
    enabled: false
    name: wxt

  # We want a cluster ip assigned
  service:
    clusterIP: ''

  # We don't need a persistent volume, since it's stored in Azure
  persistence:
    enabled: false
EOF
}
```

## Variables Values

| Name                 | Type   | Required | Value                                               |
| -------------------- | ------ | -------- | --------------------------------------------------- |
| chart_version        | string | yes      | Version of the Helm Chart                           |
| dependencies         | string | yes      | Dependency name refering to namespace module        |
| helm_service_account | string | yes      | The service account for Helm to use                 |
| helm_namespace       | string | yes      | The namespace Helm will install the chart under     |
| helm_repository      | string | yes      | The repository where the Helm chart is stored       |
| values               | list   | no       | Values to be passed to the Helm Chart               |

## History

| Date     | Release    | Change      |
| -------- | ---------- | ----------- |
| 20190909 | 20190909.1 | 1st release |
