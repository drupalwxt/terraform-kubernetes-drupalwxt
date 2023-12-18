# Terraform Kubernetes for Drupal WxT

## Introduction

This module deploys and configures Drupal WxT inside a Kubernetes Cluster.

## Security Controls

The following security controls can be met through configuration of this template:

- TBD

## Dependencies

- None

## Optional (depending on options configured)

- None

## Usage

```terraform
module "helm_drupalwxt" {
  source = "git::https://github.com/drupalwxt/terraform-kubernetes-drupalwxt.git"

  chart_version = "0.6.8"
  depends_on = [
    module.namespace_drupal,
    module.drupal_database,
  ]

  helm_namespace  = "drupal"
  helm_repository = "https://drupalwxt.github.io/helm-drupal"

  values = <<EOF
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    kubernetes.io/ingress.class: istio
  path: /*
  hosts:
    - drupal.${var.ingress_domain}

drupal:
  ## Drupal image version
  ## ref: https://hub.docker.com/drupalwxt/site-wxt/tags/
  ##
  image: drupalwxt/site-wxt

  ## Note that by default we use appVersion to get image tag
  tag: 5.1.0

  ## Site configuration
  ##
  profile: wxt
  siteEmail: admin@example.com
  siteName: Drupal Install Profile (WxT)

  ## User of the application
  ##
  username: admin

  ## Application password
  ##
  password: ${var.drupal_password}

  # php-fpm healthcheck
  # Requires https://github.com/renatomefi/php-fpm-healthcheck in the container.
  # (note: official images do not contain this feature yet)
  healthcheck:
    enabled: true

  # Switch to canada.ca theme (only used if install and/or reconfigure are enabled)
  # Common options include: theme-wet-boew, theme-gcweb-legacy
  wxtTheme: theme-gcweb

  ## Extra settings.php settings
  ##
  extraSettings: |-
    $settings['trusted_host_patterns'] = ['^drupal\.example\.ca$', '^drupalwxt-nginx$'];

  ## Extra CLI scripts
  ##
  extraInstallScripts: ''
  #  |-
  #  drush config-set system.performance js.preprocess 0 -y;
  #  drush config-set system.performance css.preprocess 0 -y;

  # Install Drupal automatically
  install: true

  # Run migrations for default content
  migrate: true

  # Reconfigure on upgrade
  reconfigure: true

  # php-fpm healthcheck
  # Requires https://github.com/renatomefi/php-fpm-healthcheck in the container.
  # (note: official images do not contain this feature yet)
  healthcheck:
    enabled: true

  # Allows custom /var/www/html/sites/default/files and /var/www/private mounts
  disableDefaultFilesMount: true

  # kubectl create secret generic drupal-storage --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT_NAME --from-literal=azurestorageaccountkey=$STORAGE_KEY -n drupal
  volumes:
    - name: files-public
      azureFile:
        secretName: drupal-storage
        shareName: drupal-public
    - name: files-private
      azureFile:
        secretName: drupal-storage
        shareName: drupal-private

  volumeMounts:
    - name: files-public
      mountPath: /var/www/html/sites/default/files
    - name: files-private
      mountPath: /var/www/private

  initContainers:
    # Pre-create the media-icons folder
    - name: init-media-icons-folder
      image: alpine:3.10
      command:
        - mkdir
        - -p
        - /files/media-icons/generic
      volumeMounts:
        - name: files-public
          mountPath: /files

nginx:
  tag: 5.1.0

  # Set your cluster's DNS resolution service here
  resolver: 10.0.0.10

  # kubectl create secret generic drupal-storage --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT_NAME --from-literal=azurestorageaccountkey=$STORAGE_KEY -n drupal
  volumes:
    - name: files-public
      azureFile:
        secretName: drupal-storage
        shareName: drupal-public

  volumeMounts:
    - name: files-public
      mountPath: /var/www/html/sites/default/files

external:
  enabled: true
  driver: pgsql
  port: 5432
  host: 127.0.0.1
  database: drupal
  user: ${module.drupal_database.administrator_login}@${module.drupal_database.name}
  password: ${var.managed_postgresql_password}

files:
  provider: none

minio:
  enabled: false

mysql:
  enabled: false

postgresql:
  enabled: false
  pgbouncer:
    enabled: true
    host: ${module.drupal_database.name}.postgres.database.azure.com
    user: ${module.drupal_database.administrator_login}@${module.drupal_database.name}
    password: ${var.managed_postgresql_password}
    poolSize: 25
    maxClientConnections: 500

redis:
  enabled: true

varnish:
  enabled: true
EOF
}
```

## Variables Values

| Name            | Type   | Required | Value                                           |
| --------------- | ------ | -------- | ----------------------------------------------- |
| chart_version   | string | yes      | Version of the Helm Chart                       |
| helm_namespace  | string | yes      | The namespace Helm will install the chart under |
| helm_repository | string | yes      | The repository where the Helm chart is stored   |
| values          | list   | no       | Values to be passed to the Helm Chart           |

## History

| Date     | Release    | Change                                                 |
| -------- | ---------- | ------------------------------------------------------ |
| 20210829 | 20210829.1 | Update to latest Terraform compatibility 1.0.x         |
| 20190909 | 20190909.1 | 1st release                                            |
| 20191220 | 20191220.1 | Updates to specification as Azure File is now in chart |
