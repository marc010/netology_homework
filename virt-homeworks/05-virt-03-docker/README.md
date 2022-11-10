
# Домашнее задание к занятию "3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

1. Загружаем и запускаем оригинальный образ с Docker hub:
   * -d запуск в фоне
   * -p проброс порта (первый параметр локальный порт, второй порт в докере)
   * --name локальное имя контейнера
```bash
$ docker run -d -p 8090:80 --name origin-nginx nginx
```

2. Проверяем работу докера:
```bash
$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                   NAMES
d9f799168dbe   nginx     "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes   0.0.0.0:8090->80/tcp, :::8090->80/tcp   origin-nginx
$ curl localhost:8090
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
3. Приготовим файл index.html для запсис в докер
```bash
$ cat index.html 
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
4. Копируес измененный файл в контейнер
```bash
$ docker cp index.html origin-nginx:/usr/share/nginx/html 
```

5. Проверяем измененя в файле:
```bash
$ curl localhost:8090
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```

6. Создаем новый образ:
```bash
$ docker commit origin-nginx test_netology_nginx 
```
7. Логинемся на Docker hub:
```bash
$ docker login
```
8. Переименовываем docker image:
```bash
$ docker tag test_netology_nginx itrevmarc/test_netology_nginx
```
9. Пушим image в репозиторий:
```bash
$ docker push itrevmarc/test_netology_nginx
```

---
Дороботка.

1. Создаем Dockerfile
```
FROM nginx

COPY ./index.html /usr/share/nginx/html
```
2. Собираем докер
```bash
$ docker build -t itrevmarc/test_netology_nginx1 .
Sending build context to Docker daemon  3.072kB
Step 1/2 : FROM nginx
 ---> 76c69feac34e
Step 2/2 : COPY ./index.html /usr/share/nginx/html
 ---> 8f1084791570
Successfully built 8f1084791570
Successfully tagged itrevmarc/test_netology_nginx1:latest
```
3. Запускаем и проверяем
```bash
$ docker run --name nginx_via_dockerfile --rm -d -p 80:80 itrevmarc/test_netology_nginx1 
fe629cff5b7c5b5d4931d69dd30eb6dc4ee2cb8d0735d1c06ad358443e5c33c2 
$ curl localhost
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
4. Пушим образ на docker hub
```bash
 $ docker push itrevmarc/test_netology_nginx1 
Using default tag: latest
The push refers to repository [docker.io/itrevmarc/test_netology_nginx1]
b9175a932109: Pushed 
a2e59a79fae0: Mounted from itrevmarc/test_netology_nginx 
4091cd312f19: Mounted from itrevmarc/test_netology_nginx 
9e7119c28877: Mounted from itrevmarc/test_netology_nginx 
2280b348f4d6: Mounted from itrevmarc/test_netology_nginx 
e74d0d8d2def: Mounted from itrevmarc/test_netology_nginx 
a12586ed027f: Mounted from itrevmarc/test_netology_nginx 
latest: digest: sha256:e96fc42ef68621c90edb118d1c2a6ddcea34dc8f81296734e5b324fb0ab00fac size: 1777
```

### Ответ: https://hub.docker.com/r/itrevmarc/test_netology_nginx1

---
## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
```
Физическая машина. Излишняя виртуализация снизит производительность java приложения.
```
- Nodejs веб-приложение;
```
Docker. Позволяет быстро развернуть приложение со всеми необходимыми зависимостями.
Удобно для разбиения на микросервисы.
``` 
- Мобильное приложение c версиями для Android и iOS;
```
Docker. Подойдет для тестирования приложений. 
```
- Шина данных на базе Apache Kafka;
```
Docker. Есть возможность быстро поднимать новые docker ноды при повышении нагрузки, а также позволит
организовать отказоустройчивость.
```
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
```
Docker. Удобно для кластеризации.
```
- Мониторинг-стек на базе Prometheus и Grafana;
```
Docker. Отдельный контейнер для Prometheus и для Grafana.
```
- MongoDB, как основное хранилище данных для java-приложения;
```
Docker или виртуальная машина. Зависит от загруженности СУБД.
```
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.
```
Виртуальная машина. Удобство бэкапироавния и миграции машины в кластере.
```


## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

1. Запуск контейнера. 
-d запуск контейнера в фоновом режиме; 
-it запускает терминал; 
--rm удаляет контейнер после ваполнения; 
--name указывает имя контейнера;
-v монтирует каталог в контейнер;
```bash
$ docker run -d -it --rm --name centos -v $(pwd)/data:/data centos
$ docker run -d -it --rm --name debian -v $(pwd)/data:/data debian
```
2. Подключение к первому контейнеру и создание файла
```bash
$ docker exec -it centos bash
[root@81c9631782ce /]# echo "String from the first docker (centos)" > /data/file1.txt
[root@81c9631782ce /]# cat /data/file1.txt 
String from the first docker (centos)
[root@81c9631782ce /]# exit
```
3. Добавление файла с хостовой машины

```bash
$ echo "String from the host!" > $(pwd)/data/file2.txt
```
4. Подключение во второй контейнер и отображение содержимого
```bash
$ docker exec -it debian bash
root@dcb1b84e100c:/# cd /data
root@dcb1b84e100c:/data# ls
file1.txt  file2.txt
```


## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

### Ответ: https://hub.docker.com/r/itrevmarc/ansible

Аналогично первому заданию.