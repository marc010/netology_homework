# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/virt-11/additional).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

docker-compose.yaml:

```
---
version: '3.1'

services:

  db:
    image: mysql:8
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "123456"
    volumes:
      - ./test_data:/media/mysql/backup
      - ./db-data:/var/lib/mysql

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080

```

Запуск контейнера:

```bash
$ docker-compose up -d
```

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-03-mysql/test_data) и 
восстановитесь из него.

* Для восстановления БД MySQL как новую сначала нужно создать базу данных, с тем же названием, как и на сервере.
    ```bash
   # head test_dump.sql 
   -- MySQL dump 10.13  Distrib 8.0.21, for Linux (x86_64)
   -- Host: localhost    Database: test_db
  ...
  # mysql -u root -p123456
  mysql> CREATE DATABASE test_db
    ```
* Восстановление БД:
   ```bash
   # cat config.cnf
   [client]
   user = "root"
   password = "123456"
   # mysql --defaults-extra-file=./config.cnf test_db < /media/mysql/backup/test_dump.sql
   ```

Перейдите в управляющую консоль `mysql` внутри контейнера.

```bash
$ docker exec -it 06-db-03-mysql_db_1 bash
# mysql --defaults-extra-file=./config.cnf
```

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

```
mysql> \s
--------------
mysql  Ver 8.0.31 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:		33
Current database:	
Current user:		root@localhost
SSL:			Not in use
Current pager:		stdout
Using outfile:		''
Using delimiter:	;
Server version:		8.0.31 MySQL Community Server - GPL
Protocol version:	10
Connection:		Localhost via UNIX socket
Server characterset:	utf8mb4
Db     characterset:	utf8mb4
Client characterset:	latin1
Conn.  characterset:	latin1
UNIX socket:		/var/run/mysqld/mysqld.sock
Binary data as:		Hexadecimal
Uptime:			31 min 10 sec

Threads: 2  Questions: 207  Slow queries: 0  Opens: 233  Flush tables: 3  Open tables: 147  Queries per second avg: 0.110
--------------
```

Версия: 8.0.31

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

```
mysql> \r test_db
mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```

**Приведите в ответе** количество записей с `price` > 300.

**Ответ:**
```
mysql> SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

```
mysql> CREATE USER 'test' IDENTIFIED WITH mysql_native_password BY 'test-password' WITH MAX_QUERIES_PER_HOUR 100 PASSWORD EXPIRE INTERVAL 180 DAY FAILED_LOGIN_ATTEMPTS 3 ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';
```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

```
mysql> GRANT SELECT ON test_db.* TO test;
```

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

**Ответ:**

```
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user = 'test';
+------+------+---------------------------------------+
| USER | HOST | ATTRIBUTE                             |
+------+------+---------------------------------------+
| test | %    | {"fname": "James", "lname": "Pretty"} |
+------+------+---------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

```
mysql> SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'test_db';
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
1 row in set (0.00 sec)
```

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

```
mysql> show profiles;
+----------+------------+-----------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                   |
+----------+------------+-----------------------------------------------------------------------------------------+
|        1 | 0.00018475 | select * from orders                                                                    |
|        2 | 0.02259350 | SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES                                |
|        3 | 0.00052800 | SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'test-db' |
|        4 | 0.00058750 | SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'test_db' |
|        5 | 0.02417450 | ALTER TABLE orders ENGINE = MyISAM                                                      |
|        6 | 0.02245275 | ALTER TABLE orders ENGINE = InnoDB                                                      |
+----------+------------+-----------------------------------------------------------------------------------------+
6 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.
(У меня этот файл находится по пути /etc/my.cnf)

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

```
[mysqld]

skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid

[client]

socket=/var/run/mysqld/mysqld.sock

!includedir /etc/mysql/conf.d/

innodb_flush_method = O_DSYNC
innodb_file_per_table = 1
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 600M
innodb_log_file_size = 100M
```