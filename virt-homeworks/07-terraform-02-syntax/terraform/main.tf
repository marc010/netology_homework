provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "netology-first" {
  name = "test-vm"

  resources {
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd864gbboths76r8gm5f"
    }
  }

  network_interface {
    subnet_id = "e9becg8tafkc48jn84ls" 
#    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

}
output "internal_ip_address_test_vm" {
  value = yandex_compute_instance.netology-first.network_interface.0.ip_address
}

output "external_ip_address_test_vm" {
  value = yandex_compute_instance.netology-first.network_interface.0.nat_ip_address
}
