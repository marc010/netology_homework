# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

docker-compose.yaml:
```
---
version: "3.1"

services:

        postgres-db:
                image: postgres:12
                restart: always
                environment:
                        POSTGRES_PASSWORD: "123456"
                volumes:
                        - ./db-data:/var/lib/postgresql/data
                        - ./db-backup:/var/backups/postgresql/backup

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
## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
```
CREATE USER "test-admin-user";
CREATE DATABASE test_db;
```
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
```
CREATE TABLE orders (id SERIAL PRIMARY KEY, "наименование" varchar, "цена" INT);
CREATE TABLE clients (id SERIAL PRIMARY KEY, "фамилия" VARCHAR, "страна проживания" VARCHAR, "заказ" INT, FOREIGN KEY (заказ) REFERENCES orders (id));
```
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
```
GRANT ALL ON clients, orders TO "test-admin-user";
```
- создайте пользователя test-simple-user 
```
CREATE USER "test-simple-user";
```
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
```
GRANT SELECT, INSERT, UPDATE, DELETE ON clients, orders TO "test-simple-user";
```


Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше
```bash
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

```
- описание таблиц (describe)
```bash
test_db-# \d orders
                                    Table "public.orders"
    Column    |       Type        | Collation | Nullable |              Default               
--------------+-------------------+-----------+----------+------------------------------------
 id           | integer           |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character varying |           |          | 
 цена         | integer           |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
```
```bash
test_db-# \d clients
                                       Table "public.clients"
      Column       |       Type        | Collation | Nullable |               Default               
-------------------+-------------------+-----------+----------+-------------------------------------
 id                | integer           |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | character varying |           |          | 
 страна проживания | character varying |           |          | 
 заказ             | integer           |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```
SELECT grantor, grantee, table_catalog, table_name, privilege_type FROM information_schema.table_privileges WHERE grantee in ('test-admin-user','test-simple-user')
```
- список пользователей с правами над таблицами test_db
```
postgres	test-admin-user     orders	INSERT
postgres	test-admin-user	    orders	SELECT
postgres	test-admin-user	    orders	UPDATE
postgres	test-admin-user	    orders	DELETE
postgres	test-admin-user	    orders	TRUNCATE
postgres	test-admin-user	    orders	REFERENCES
postgres	test-admin-user	    orders	TRIGGER
postgres	test-simple-user    orders	INSERT
postgres	test-simple-user    orders	SELECT
postgres	test-simple-user    orders	UPDATE
postgres	test-simple-user    orders	DELETE
postgres	test-admin-user	    clients	INSERT
postgres	test-admin-user	    clients	SELECT
postgres	test-admin-user	    clients	UPDATE
postgres	test-admin-user	    clients	DELETE
postgres	test-admin-user	    clients	TRUNCATE
postgres	test-admin-user	    clients	REFERENCES
postgres	test-admin-user	    clients	TRIGGER
postgres	test-simple-user    clients	INSERT
postgres	test-simple-user    clients	SELECT
postgres	test-simple-user    clients	UPDATE
postgres	test-simple-user    clients	DELETE
```
## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders
```
INSERT INTO orders (наименование, цена) VALUES ('Шоколад', 10), ('Принтер', 3000), ('Книга', 500), ('Монитор', 7000), ('Гитара', 4000);
```

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

```
INSERT INTO clients ("фамилия", "страна проживания") VALUES ('Иванов Иван Иванович', 'USA'), ('Петров Петр Петрович', 'Canada'), ('Иоганн Себастьян Бах', 'Japan'), ('Ронни Джеймс Дио', 'Russia'), ('Ritchie Blackmore', 'Russia');
```

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

```bash
test_db=# select count(id) from orders;
 count 
-------
     5
(1 row)

test_db=# SELECT COUNT(id) FROM clients;
 count 
-------
     5
(1 row)
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

```
UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование" = 'Книга') WHERE "фамилия" = 'Иванов Иван Иванович';
UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование" = 'Монитор') WHERE "фамилия" = 'Петров Петр Петрович';
UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование" = 'Гитара') WHERE "фамилия" = 'Иоганн Себастьян Бах';
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
```bash
# SELECT * FROM clients WHERE заказ IS NOT NULL;
 id |       фамилия        | страна проживания | заказ 
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)
```

Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

```bash
# EXPLAIN SELECT * FROM clients WHERE заказ IS NOT NULL;
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..18.10 rows=806 width=72)
   Filter: ("заказ" IS NOT NULL)
(2 rows)
```

Числа, перечисленные в скобках (слева направо), имеют следующий смысл:

* Приблизительная стоимость запуска. Это время, которое проходит, прежде чем начнётся этап вывода данных,
например для сортирующего узла это время сортировки.

* Приблизительная общая стоимость. Она вычисляется в предположении, что узел плана выполняется до конца,
то есть возвращает все доступные строки. На практике родительский узел может досрочно прекратить чтение
строк дочернего.

* Ожидаемое число строк, которое должен вывести этот узел плана. При этом так же предполагается,
что узел выполняется до конца.

* Ожидаемый средний размер строк, выводимых этим узлом плана (в байтах).

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

```bash
# pg_dumpall -h localhost -U postgres > /var/backups/postgresql/backup/$(date --iso-8601)_backup
```

Остановите контейнер с PostgreSQL (но не удаляйте volumes).
```bash
$ docker-compose down
Stopping 06-db-02-sql_adminer_1     ... done
Stopping 06-db-02-sql_postgres-db_1 ... done
Removing 06-db-02-sql_adminer_1     ... done
Removing 06-db-02-sql_postgres-db_1 ... done
Removing network 06-db-02-sql_default
$ docker-compose ps
Name   Command   State   Ports
------------------------------
```
Поднимите новый пустой контейнер с PostgreSQL.

```bash
$ docker run --rm -d -v ($pwd)/db-backup:/var/backups/postgresql/backup --name backup-db-test postgres:12
```

Восстановите БД test_db в новом контейнере.

```bash
$ docker exec -it 5bb089587e4d bash
# psql -h localhost -U postgres -f /var/backups/postgresql/backup/2022-11-20_backup
```
Проверака:

```bash
root@5bb089587e4d:/var/backups/postgresql/backup# su postgres
postgres@5bb089587e4d:/var/backups/postgresql/backup$ psql
psql (12.13 (Debian 12.13-1.pgdg110+1))
Type "help" for help.

postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# \d 
               List of relations
 Schema |      Name      |   Type   |  Owner   
--------+----------------+----------+----------
 public | clients        | table    | postgres
 public | clients_id_seq | sequence | postgres
 public | orders         | table    | postgres
 public | orders_id_seq  | sequence | postgres
(4 rows)
```

Приведите список операций, который вы применяли для бэкапа данных и восстановления.
