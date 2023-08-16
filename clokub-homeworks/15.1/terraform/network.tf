resource "yandex_vpc_network" "default" {
  name        = "netology"
  description = "This is vpc for a netology project"
  folder_id   = var.yc_folder_id
}

resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public"
  description    = "This subnet is for public usage"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = var.yc_region
  network_id     = "${yandex_vpc_network.default.id}"
}


resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v1"
  zone        = var.yc_region

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat-image.id
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.public-subnet.id}"
    nat        = true
    ip_address = var.nat_instance_ip
  }

  metadata = {
    user-data = "users:\n  - name: ${var.vm_user_nat}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }
}



resource "yandex_vpc_subnet" "private-subnet" {
  name           = "private"
  description    = "This subnet is for private usage"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = var.yc_region
  network_id     = "${yandex_vpc_network.default.id}"
  route_table_id = "${yandex_vpc_route_table.nat-instance-route.id}"
}

resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = "${yandex_vpc_network.default.id}"
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "${yandex_compute_instance.nat-instance.network_interface.0.ip_address}"
  }
}