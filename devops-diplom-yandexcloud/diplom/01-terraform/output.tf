output "k8s_master1_public_ip" {
  description = "Public IP addresses for master-nodes"
  value = yandex_compute_instance.k8s-master1.network_interface.0.nat_ip_address
}

output "k8s_master1_private_ip" {
  description = "Private IP addresses for master-nodes"
  value = yandex_compute_instance.k8s-master1.network_interface.0.ip_address
}

output "k8s_workers_public_ips" {
  description = "Public IP addresses for worker-nodes"
  value = values(yandex_compute_instance.k8s-workers).*.network_interface.0.nat_ip_address
}

output "k8s_workers_private_ips" {
  description = "Private IP addresses for worker-nodes"
  value = values(yandex_compute_instance.k8s-workers).*.network_interface.0.ip_address
}