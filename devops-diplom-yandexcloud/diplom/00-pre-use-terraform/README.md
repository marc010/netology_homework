## Подготовка backend для Terraform

---

### Создание сервисного аккаунта для работы с инфраструктурой

Будет создан сервисный аккаунт с ролью:
* editor
* container-registry.images.puller

---

### Terraform конфигурация для создания S3 bucket в ЯО для хранения terraform state

1. Заполнить файл [`variables.tf`](variables.tf) указав id облака и папку где будет
создаваться инфраструктура.

   Для получения id папки:
   ```
   yc config get folder-id
   ```
   Для получения id облака:
   ```
   yc config get cloud-id
   ```

2. Проинициализировать terraform:

```bash
terrafrom init
```

3. Применить конфигурацию:

```bash
terraform apply
```

