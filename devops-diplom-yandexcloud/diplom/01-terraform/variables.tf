variable "yc_region" {
  default = "ru-central1-a"
}

variable "yc_cloud_id" {
  default = ""
}

variable "yc_folder_id" {
  default = ""
}

data "yandex_compute_image" "ubuntu-image" {
  family = "ubuntu-2204-lts"
}

locals {    # locals позволяет интерполировать значение переменных
  workers = {
    vm1 = {
      name   = "k8s-worker1"
      zone   = "ru-central1-a"
      subnet = "${yandex_vpc_subnet.public-subnet-a.id}"
    }
    vm2 = {
      name   = "k8s-worker2"
      zone   = "ru-central1-b"
      subnet = "${yandex_vpc_subnet.public-subnet-b.id}"
    }
    vm3 = {
      name   = "k8s-worker3"
      zone   = "ru-central1-c"
      subnet = "${yandex_vpc_subnet.public-subnet-c.id}"
    }
  }
}
