resource "yandex_kms_symmetric_key" "key" {
  name              = "netology"
  description       = "kms key for testing usage in an object storage"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
  lifecycle {
    prevent_destroy = false # change to true in prod
  }
}