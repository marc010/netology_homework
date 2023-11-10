## Создание секрета для доступа к private container registry

1. Получите и сохраните в файл `key.json` авторизованный ключ для вашего сервисного аккаунта:

```bash
yc iam key create --service-account-name <имя_сервисного_аккаунта> -o key.json
```

2. Выполните команду аутентификации для проверки работоспособности:

```bash
cat key.json | docker login \
  --username json_key \
  --password-stdin \
  cr.yandex
```

3. Подготвить полученный ключ для секрета в kubernetes:

```bash
cat $HOME/.docker/config.json | base64
```

4. Подставить полученное значение секрета в файл [`secret-container-registry.yaml`](secret-container-registry.yaml)