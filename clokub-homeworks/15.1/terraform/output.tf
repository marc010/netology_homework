output "external_ip_address_vm1-public" {
  value = yandex_compute_instance.vm1-public.network_interface.0.nat_ip_address
}

output "internal_ip_address_vm1-private" {
  value = yandex_compute_instance.vm1-private.network_interface.0.ip_address
}