#-- Network netology

resource "yandex_vpc_network" "diplom" {
  name        = "diplom-network"
  description = "This is vpc for the netology diplom project"
  folder_id   = var.yc_folder_id
}

#-- Public subnet in ru-central1-a

resource "yandex_vpc_subnet" "public-subnet-a" {
  name           = "public-a"
  description    = "This subnet is for public usage"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.diplom.id}"
}

#-- Public subnet in ru-central1-b

resource "yandex_vpc_subnet" "public-subnet-b" {
  name           = "public-b"
  description    = "This subnet is for public usage"
  v4_cidr_blocks = ["192.168.11.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.diplom.id}"
}

#-- Public subnet in ru-central1-c

resource "yandex_vpc_subnet" "public-subnet-c" {
  name           = "public-c"
  description    = "This subnet is for public usage"
  v4_cidr_blocks = ["192.168.12.0/24"]
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.diplom.id}"
}