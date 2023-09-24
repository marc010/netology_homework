#-- Network netology

resource "yandex_vpc_network" "default" {
  name        = "netology"
  description = "This is vpc for a netology project"
  folder_id   = var.yc_folder_id
}

#-- Public subnet in ru-central1-a

resource "yandex_vpc_subnet" "public-subnet-a" {
  name           = "public-a"
  description    = "This subnet is for public usage"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
}

#-- Public subnet in ru-central1-b

resource "yandex_vpc_subnet" "public-subnet-b" {
  name           = "public-b"
  description    = "This subnet is for public usage"
  v4_cidr_blocks = ["192.168.11.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.default.id}"
}

#-- Public subnet in ru-central1-c

resource "yandex_vpc_subnet" "public-subnet-c" {
  name           = "public-c"
  description    = "This subnet is for public usage"
  v4_cidr_blocks = ["192.168.12.0/24"]
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.default.id}"
}

#-- Nat instance for private subnets

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
    subnet_id  = "${yandex_vpc_subnet.public-subnet-a.id}"
    nat        = true
    ip_address = var.nat_instance_ip
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user_nat}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }
}

#-- Private subnet in ru-central1-a with nat

resource "yandex_vpc_subnet" "private-subnet-a" {
  name           = "private-a"
  description    = "This subnet is for private usage"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
  route_table_id = "${yandex_vpc_route_table.nat-instance-route-a.id}"
}

resource "yandex_vpc_route_table" "nat-instance-route-a" {
  name       = "nat-instance-route-a"
  network_id = "${yandex_vpc_network.default.id}"
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "${yandex_compute_instance.nat-instance.network_interface.0.ip_address}"
  }
}

#-- Private subnet in ru-central1-b with nat

resource "yandex_vpc_subnet" "private-subnet-b" {
  name           = "private-b"
  description    = "This subnet is for private usage"
  v4_cidr_blocks = ["192.168.21.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.default.id}"
  route_table_id = "${yandex_vpc_route_table.nat-instance-route-b.id}"
}

resource "yandex_vpc_route_table" "nat-instance-route-b" {
  name       = "nat-instance-route-b"
  network_id = "${yandex_vpc_network.default.id}"
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "${yandex_compute_instance.nat-instance.network_interface.0.ip_address}"
  }
}


#-- Private subnet in ru-central1-c with nat

resource "yandex_vpc_subnet" "private-subnet-c" {
  name           = "private-c"
  description    = "This subnet is for private usage"
  v4_cidr_blocks = ["192.168.22.0/24"]
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.default.id}"
  route_table_id = "${yandex_vpc_route_table.nat-instance-route-c.id}"
}

resource "yandex_vpc_route_table" "nat-instance-route-c" {
  name       = "nat-instance-route-c"
  network_id = "${yandex_vpc_network.default.id}"
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "${yandex_compute_instance.nat-instance.network_interface.0.ip_address}"
  }
}
