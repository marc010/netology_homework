provider "yandex" {
  zone = var.yc_region
  cloud_id = var.yc_cloud_id
  folder_id = var.yc_folder_id
}

resource "yandex_compute_instance" "vm-count" {
  count = local.vm_count[terraform.workspace]
  name = "${var.vm_name_pfx}-${count.index}"
  platform_id = local.platform_id_type[terraform.workspace]

  resources {
    cores = 2
    memory = 2
  }
  
  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu22_id}"
    }
  }

  network_interface {
    subnet_id = "${var.subnet}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

}

output "internal_ip_address_count" {
  value = yandex_compute_instance.vm-count.*.network_interface.0.ip_address
}


output "external_ip_address_count" {
  value = yandex_compute_instance.vm-count.*.network_interface.0.nat_ip_address
}

resource "yandex_compute_instance" "vm-foreach" {
  for_each = var.vm_names
  name = each.value.name
  platform_id = local.platform_id_type[terraform.workspace]

  resources {
    cores = 2
    memory = 2
  }
  
  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu22_id}"
    }
  }

  network_interface {
    subnet_id = "${var.subnet}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

}

output "internal_ip_address_foreach" {
  value = values(yandex_compute_instance.vm-foreach).*.network_interface.0.ip_address
}

output "external_ip_address_foreach" {
  value = values(yandex_compute_instance.vm-foreach).*.network_interface.0.nat_ip_address
}

resource "yandex_compute_instance" "always-present-vm" {
  name = "vm100"
  resources {
    cores = 2
    memory = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu22_id}"
    }
  }

  network_interface {
    subnet_id = "${var.subnet}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
output "internal_ip_address_always_present_vm" {
  value = yandex_compute_instance.always-present-vm.network_interface.0.ip_address
}
output "external_ip_address_always_present_vm" {
  value = yandex_compute_instance.always-present-vm.network_interface.0.nat_ip_address
}
