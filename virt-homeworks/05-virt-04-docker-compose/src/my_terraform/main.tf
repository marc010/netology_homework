provider "yandex" {
    cloud_id = ""
    folder_id = ""
    zone = "ru-central1-a"
    token = ""
}

terraform {
    required_providers {
        yandex = {
            source = "yandex-cloud/yandex"
        }
    }
    backend "local" {
        path = "terraform.tfstate"
    }
}

resource "yandex_compute_instance" "default" {
    name = "vm-1"
    hostname = "vm-1"
    description = "test vm"
    zone = "ru-central1-a"
    platform_id = "standard-v1"

    allow_stopping_for_update = true
    
    resources {
        cores = 2
        memory = 4
    }
    
    boot_disk {
        initialize_params {
            image_id = ""
            size = 20
            type = "network-ssd"
        }
    }
    network_interface {
        subnet_id = ""
        nat = true
    }

    metadata = {
        ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
    }


}

