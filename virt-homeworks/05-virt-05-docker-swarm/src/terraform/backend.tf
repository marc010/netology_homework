terraform {
    required_providers {
        yandex = {
            source = "yandex-cloud/yandex"
        }
    }
    backend "local" {
        path = "terraform.tfstate"
    }
}
vag
