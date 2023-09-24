data "yandex_compute_image" "nat-image" {
  family = "nat-instance-ubuntu"
}

data "yandex_compute_image" "ubuntu-image" {
  family = "ubuntu-2204-lts"
}

variable "vm_user" {
  default = "user"
}

variable "vm_user_nat" {
  default = "userNAT"
}

variable "ssh_key_path" {
  default = "~/.ssh/id_rsa_yc.pub"
}

variable "nat_instance_ip" {
  default = "192.168.10.254"
}

variable "yc_region" {
  default = "ru-central1-a"
}

variable "yc_cloud_id" {
  default = ""
}

variable "yc_folder_id" {
  default = ""
}

variable "mysql_env" {
  default = "PRESTABLE"
}

variable "mysql_version" {
  default = "8.0"
}

variable "mysql_user" {
  default = ""
}

variable "mysql_password" {
  default = ""
}

variable "k8s_version" {
  default = "1.27"
}