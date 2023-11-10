output "static_access_key" {
  description = "backet access_key"
  value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
}

output "static_secret_key" {
  description = "backet secret_key"
  sensitive = true
  value = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}