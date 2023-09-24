resource "yandex_mdb_mysql_cluster" "my-mysql" {
  name                = "my-mysql"
  environment         = var.mysql_env
  network_id          = "${yandex_vpc_network.default.id}"
  version             = var.mysql_version
  deletion_protection = true

  maintenance_window {
    type = "ANYTIME"
  }

  backup_window_start {
    hours   = 23
    minutes = 59
  }

  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-hdd"
    disk_size          = 20
  } 

  host {
    zone             = "ru-central1-a"
    subnet_id        = "${yandex_vpc_subnet.private-subnet-a.id}"
    assign_public_ip = false
    backup_priority  = 10
  }

  host {
    zone             = "ru-central1-b"
    subnet_id        = "${yandex_vpc_subnet.private-subnet-b.id}"
    assign_public_ip = false
  }

  host {
    zone             = "ru-central1-c"
    subnet_id        = "${yandex_vpc_subnet.private-subnet-c.id}"
    assign_public_ip = false
  }
}

resource "yandex_mdb_mysql_database" "netology-db" {
  cluster_id = "${yandex_mdb_mysql_cluster.my-mysql.id}"
  name       = "netology_db"
}

resource "yandex_mdb_mysql_user" "mysql-user" {
  cluster_id = "${yandex_mdb_mysql_cluster.my-mysql.id}"
  name       = var.mysql_user
  password   = var.mysql_password
  permission {
    database_name = yandex_mdb_mysql_database.netology-db.name
    roles         = ["ALL"]
  }
}
