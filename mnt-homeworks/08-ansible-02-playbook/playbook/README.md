## Playbook clickhouse and vector

---

Плэйбук предназначен для установки clickhouse и vector на соответствующих в инвенторе файле хостах.


### group_vars

* clickhouse_version  - версия clickhouse;
* clickhouse_packages - необходимые для установки clickhouse'а пакеты;
* vector_version      - версия vector;

### inventory

* Группа clickhouse - 1 хост clickhouse-01
* Группа vector     - 1 хост vector-01

### playbook

* Play "Install Clickhouse" применяется на группу хостов "Clickhouse" и предназначен для установки и запуска Clickhouse;
* Play "Install Vector" применяется на группу хостов "Vector" и предназначен для установки и запуска Vector;

### tags

* clickhouse;
* vector;

