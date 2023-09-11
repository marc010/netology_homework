terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  required_version = ">= 0.13"
}

provider "yandex" {
  zone = var.yc_region
  cloud_id = var.yc_cloud_id
  folder_id = var.yc_folder_id
}