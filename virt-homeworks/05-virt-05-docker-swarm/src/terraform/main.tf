resource "yandex_compute_instance" "manager" {
    count = 3

    name = format("manager-%02d", count.index + 1)
    hostname = format("manager-%02d", count.index + 1)
    description = format("manager-%02d", count.index + 1)
    zone = "ru-central1-a"
    platform_id = "standard-v1"

    allow_stopping_for_update = true
    
    resources {
        cores = 2
        memory = 4
    }
    
    boot_disk {
        initialize_params {
            image_id = "fd825kmhbreush4tlu3m"
            size = 20
            type = "network-ssd"
        }
    }
    network_interface {
        subnet_id = "e9bd3je78ot909p0her4"
        nat = true
    }

    metadata = {
        ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
    }
}

resource "yandex_compute_instance" "worker" {
    count = 3

    name = format("worker-%02d", count.index + 1)
    hostname = format("worker-%02d", count.index + 1)
    description = format("worker-%02d", count.index + 1)
    zone = "ru-central1-a"
    platform_id = "standard-v1"

    allow_stopping_for_update = true
    
    resources {
        cores = 2
        memory = 4
    }
    
    boot_disk {
        initialize_params {
            image_id = "fd825kmhbreush4tlu3m"
            size = 20
            type = "network-ssd"
        }
    }
    network_interface {
        subnet_id = "e9bd3je78ot909p0her4"
        nat = true
    }

    metadata = {
        ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
    }
}

