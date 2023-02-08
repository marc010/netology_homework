## Playbook clickhouse and vector

---

### Описание

Плэйбук предназначен для установки clickhouse и vector.

---

### Requerements

* Ansible >= 2.10

### Variables
| name                | Default value                                                      | Description                                   | 
|---------------------|--------------------------------------------------------------------|-----------------------------------------------| 
| clickhouse_version  | 22.3.3.44                                                          | версия clickhouse                             |
| clickhouse_packages | [ clickhouse-client, clickhouse-server, clickhouse-common-static ] | необходимые для установки clickhouse'а пакеты |
| vector_version      | 0.27.0                                                             | версия vector                                 | 



### inventory

* Группа clickhouse - 1 хост clickhouse-01
* Группа vector     - 1 хост vector-01

### Playbook

* Play "Install Clickhouse" применяется на группу хостов "Clickhouse" и предназначен для установки и запуска Clickhouse;
* Play "Install Vector" применяется на группу хостов "Vector" и предназначен для установки и запуска Vector;

### Tags

| name     | Description                  |
|----------|------------------------------|
| install  | only intallation of packages |
| download | only downloading of packages |

### License

MIT

