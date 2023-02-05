## Playbook clickhouse and vector

---

### что делает playbook

Плэйбук скачивает и устанавливает указанные версии clickhous, lighthouse и vector на соответствующих в инвенторе хостах.


### параметры

* ip адреса. Указавается в файле ./inventory/prod.yml;
* Версии clickhouse и vector. Указываются в файлах ./group_vars/clickhouse/vars.yml и ./group_vars/vector/vars.yml соответственно;

### теги

* clickhouse
* vector
* lighthouse
