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
}

module "instance" {
  source = "git::https://github.com/marc010/terraform.git//modules/yandex_compute_instance"  
  instance_count = 2
  subnet = "${var.subnet}"
  folder_id = var.yc_folder_id
}