resource "yandex_iam_service_account" "ig-sa" {
  name        = "ig-sa"
  description = "service account to manage Instance Group"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id  = var.yc_folder_id
  role       = "editor"
  member     = "serviceAccount:${yandex_iam_service_account.ig-sa.id}"
  depends_on = [
    yandex_iam_service_account.ig-sa,
  ]
}

resource "yandex_compute_instance_group" "lamp-vms" {
  name                = "vm-lamp"
  folder_id           = var.yc_folder_id
  service_account_id  = "${yandex_iam_service_account.ig-sa.id}"
  depends_on          = [yandex_resourcemanager_folder_iam_member.editor]
  deletion_protection = false

  load_balancer {
    target_group_name = "lamp-vms"
  }

  instance_template {
    platform_id = "standard-v1"

    resources {
      core_fraction = 20
      cores         = 2
      memory        = 2
    }
  
    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.lamp-image.id
      }
    }

    network_interface {
      subnet_ids  = ["${yandex_vpc_subnet.public-subnet.id}"]
      nat         = true
    }

    metadata = {
      user-data = "${file("lamp-init.yaml")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  
  allocation_policy {
    zones = ["ru-central1-a"]
  }


  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

}
