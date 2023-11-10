terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "for-state"
    region = "ru-central1"
    key = "for-state/terraform.tfstate"
    skip_region_validation = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  zone = var.yc_region
  cloud_id = var.yc_cloud_id
  folder_id = var.yc_folder_id
}