output "puplic_ip" {
  value = values(yandex_compute_instance.vm).*.network_interface.0.nat_ip_address 
}