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

data "yandex_compute_image" "image" {
  family = var.image
}

resource "yandex_compute_instance" "vm" { 
  for_each = var.vm_names

  name = each.value.name
  platform_id = "standard-v1"
  folder_id = var.yc_folder_id

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      size = 20
    }
  }
  
  network_interface {
    subnet_id = "${var.subnet}"
    nat = "${var.nat}"
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}