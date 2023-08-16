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
  default = "b1gj228gu73k9ver1kdb"
}

variable "yc_folder_id" {
  default = "b1gj228gu73k9ver1kdb"
}

variable "nat_image_id" {
  default = "fd8qmbqk94q6rhb4m94t"
}