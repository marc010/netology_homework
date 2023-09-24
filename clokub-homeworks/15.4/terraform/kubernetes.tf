resource "yandex_kubernetes_cluster" "k8s-regional" {
  name       = "k8s-netology"
  network_id = "${yandex_vpc_network.default.id}"
  release_channel = "RAPID"
  network_policy_provider = "CALICO"

  master {
    version  = var.k8s_version
    public_ip = true

    regional {
      region = "ru-central1"

      location {
        zone      = "${yandex_vpc_subnet.private-subnet-a.zone}"
        subnet_id = "${yandex_vpc_subnet.private-subnet-a.id}"
      }

      location {
        zone      = "${yandex_vpc_subnet.private-subnet-b.zone}"
        subnet_id = "${yandex_vpc_subnet.private-subnet-b.id}"
      }

      location {
        zone      = "${yandex_vpc_subnet.private-subnet-c.zone}"
        subnet_id = "${yandex_vpc_subnet.private-subnet-c.id}"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.sa-k8s.id
  node_service_account_id = yandex_iam_service_account.sa-k8s.id

  kms_provider {
    key_id = yandex_kms_symmetric_key.key.id
  }
}


resource "yandex_kubernetes_node_group" "node_group" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-regional.id}"
  name        = "node-group"
  version     = var.k8s_version

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.public-subnet-a.id}"]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      min     = 3
      max     = 6
      initial = 3
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "15:00"
      duration   = "3h"
    }

    maintenance_window {
      day        = "friday"
      start_time = "10:00"
      duration   = "4h30m"
    }
  }
}
