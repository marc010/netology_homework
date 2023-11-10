resource "yandex_compute_instance" "k8s-master1" {
  name        = "k8s-master1"
  platform_id = "standard-v1"
  description = "Master нода кластера k8s"
  zone        = var.yc_region
  folder_id   = var.yc_folder_id

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-image.id
      size     = 20
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public-subnet-a.id
    nat        = true
  }

  metadata = {
    user-data = file("cloud_config.yaml")
  }
}

resource "yandex_compute_instance" "k8s-workers" {
  for_each = local.workers
  name        = each.value.name
  platform_id = "standard-v1"
  description = "Worker нода кластера k8s"
  zone        = each.value.zone

  resources {
    core_fraction = 5
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-image.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = each.value.subnet
    nat       = true
  }

  metadata = {
    user-data = file("cloud_config.yaml")
  }
}