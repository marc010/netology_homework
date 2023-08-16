resource "yandex_compute_instance" "vm1-public" {
  name        = "vm1-public"
  platform_id = "standard-v1"
  zone        = var.yc_region

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-image.id
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.public-subnet.id}"
    nat        = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }
}


resource "yandex_compute_instance" "vm1-private" {
  name        = "vm1-private"
  platform_id = "standard-v1"
  zone        = var.yc_region

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-image.id
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.private-subnet.id}"
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }
}
