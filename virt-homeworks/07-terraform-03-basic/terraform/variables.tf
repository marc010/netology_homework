variable "yc_token" {
  default = ""
}

variable "yc_cloud_id" {
  default = ""
}

variable "yc_folder_id" {
  default = ""
}

variable "yc_region" {
  default = "ru-central1-a"
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "ubuntu22_id" {
  default = ""
}

variable "subnet" {
  default = ""
}

variable "vm_name_pfx" {
  description = "VM Names"
  default = "netology-vm-"
  type = string
}

variable "vm_names" {
  type = map
  default = {
    vm1 = {
      name = "vm-1f"
    }
    vm2 = {
      name = "vm-2f"
    }
  }
}


locals {
  vm_count = {
    stage = 1
    prod = 2
  }
}

locals {
  platform_id_type = {
    stage = "standard-v1"
    prod = "standard-v2"
  }
}

