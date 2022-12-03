# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

docker-compose.yaml:
```
---
version: "3.1"

services:

        postgres-db:
                image: postgres:13
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

Подключитесь к БД PostgreSQL используя `psql`.

```bash
$ docker exec -it 06-db-04-postgresql_postgres-db_1 bash
root@383595eca6fc:/# su postgres
postgres@383595eca6fc:/$ psql
```

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
```
\l[+]   [PATTERN]      list databases
```
- подключения к БД
```
\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo} connect to new database (currently "postgres")
```
- вывода списка таблиц
```
\dt[S+] [PATTERN]      list tables
```
- вывода описания содержимого таблиц
```
\d[S+]  NAME           describe table, view, sequence, or index
```
- выхода из psql
```
\q                     quit psql
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

```bash
$ psql -h localhost -U postgres test_database < /var/backups/postgresql/backup/test_dump.sql
```

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

```bash
$ psql
postgres=# \c test_database
test_database=# ANALYZE;
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

```bash
SELECT attname,avg_width FROM pg_stats WHERE tablename = 'orders' ORDER BY avg_width DESC LIMIT 1;
 attname | avg_width 
---------+-----------
 title   |        16
(1 row)
```

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Нюансы:
* Необходимо создать временную таблицу, для сохранения исходных записей;
* Индексы, ограничения и триггеры не неследуются;

```sql
BEGIN;

ALTER TABLE orders RENAME TO orders_tmp;

CREATE TABLE orders ( 
    LIKE orders_tmp
    INCLUDING ALL
);

CREATE TABLE orders_1 (
    CHECK (price > 499)
) INHERITS (orders);

CREATE TABLE orders_2 (
    CHECK (price <= 499)
) INHERITS (orders);

CREATE RULE orders_1_price_more_than_499 AS ON INSERT TO orders
WHERE (price > 499)
DO INSTEAD INSERT INTO orders_1 VALUES (NEW.*);

CREATE RULE orders_2_price_less_or_equal_499 AS ON INSERT TO orders
WHERE (price <= 499)
DO INSTEAD INSERT INTO orders_2 VALUES (NEW.*);

INSERT INTO orders (id, title, price) SELECT id, title, price FROM orders_tmp;

DROP TABLE orders_tmp CASCADE; 

COMMIT;
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

```sql
CREATE TABLE orders_1 (
    CHECK (price > 499)
) INHERITS (orders);

CREATE TABLE orders_2 (
    CHECK (price <= 499)
) INHERITS (orders);

CREATE RULE orders_1_price_more_than_499 AS ON INSERT TO orders
WHERE (price > 499)
DO INSTEAD INSERT INTO orders_1 VALUES (NEW.*);

CREATE RULE orders_2_price_less_or_equal_499 AS ON INSERT TO orders
WHERE (price <= 499)
DO INSTEAD INSERT INTO orders_2 VALUES (NEW.*);
```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

```bash
pg_dumpall -h localhost -U postgres > /var/backups/postgresql/backup/$(date --iso-8601)_backup
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

Необходимо добавить свойство `UNIQUE` для столбца `title`, учитывая шардирование, то есть добавить свойство
свойство `UNIQUE` для столбца `title` в каждой таблице ( orders, orders_1, orders_2).
