resource "yandex_iam_service_account" "sa-bucket" {
  folder_id = var.yc_folder_id
  name      = var.yc_sa_bucket
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
  depends_on = [
    yandex_iam_service_account.sa-bucket,
  ]
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-bucket.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "pictures" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.bucket_name
  depends_on = [yandex_resourcemanager_folder_iam_member.sa-editor]

  anonymous_access_flags {
    read = true
    list = false
  }
}

resource "yandex_storage_object" "picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key  
  bucket     = var.bucket_name
  key        = "netology_logo"
  source     = "../media/netology.png"
  depends_on = [yandex_resourcemanager_folder_iam_member.sa-editor]
}