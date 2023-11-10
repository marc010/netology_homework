## Создание облачной инфраструктуры

---

### Создадим файл, в котором укажем секреты сервисного аккаунта для работы с бэкендом.

Воспользуемся выводом `terraform apply` с предыдущего этапа. Или создадим новый ключ для
сервисного аккаунта

```bash
yc iam access-key create --service-account-name bucket-sa
```

Сохраните идентификатор key_id (access_key) и секретный ключ secret (secret_key)

```bash
terraform output -raw static_secret_key
```

```bash
cat backend.cred 
access_key = ""
secret_key = ""
```

Для использования удаленного terraform state нужно это явно указывать:

```bash
terraform init --backend-config=backend.cred
```

---

### Создание VPC с подсетями в разных зонах доступности.

Создание vpc описывается в файле [`vpc.tf`](./vpc.tf). Создается VPC в трех зонах доступности,
в каждой зоне доступности создается public и private подсети, а также nat-instance.


---
### Создание инфраструктуры для Kubernetes кластера

Создание k8s кластера описывается в файле [`k8s-instances.tf`](./k8s-instances.tf). Создается 3
виртуальные машины для worker nodes в 3 зонах доступности и 1 виртуальная машина для master node
в public подсети.

```
В файле cloud_config.yaml указать публичный ssh ключ
```