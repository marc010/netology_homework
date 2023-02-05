variable "yc_cloud_id" {
  default = ""
}

variable "yc_folder_id" {
  default = ""
}

variable "subnet" {
  default = ""
}

variable "yc_region" {
  default = "ru-central1-a"
}

variable "image" {
  default = "centos-7"
}

variable "nat" {
  type = bool
  default = true
}

variable "vm_names" {
  type = map
  default = {
    clickhouse = {
      name = "clickhouse-01"
    }
    vector = {
      name = "vector-01"
    }
    lighthouse = {
      name = "lighthouse-01"
    }
  }
}