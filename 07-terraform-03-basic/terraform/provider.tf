# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "state-bucket"
    region     = "ru-central1-a"
    key        = "terraform-state/terraform.tfstate"
    access_key = "*****"
    secret_key = "*****"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"
  zone = "ru-central1-a"
}
