# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch

```
FROM centos:7

ENV ES_HOME="/var/lib/elasticsearch" 

WORKDIR ${ES_HOME}

RUN yum -y install wget perl-Digest-SHA && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.5.2-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.5.2-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-8.5.2-linux-x86_64.tar.gz.sha512 && \
    rm -f elasticsearch-8.5.2-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.5.2-linux-x86_64.tar.gz && \
    rm -f elasticsearch-8.5.2-linux-x86_64.tar.gz && \
    useradd -m elasticsearch && \
    mkdir ${ES_HOME}/data ${ES_HOME}/logs && \
    chown elasticsearch:elasticsearch -R ${ES_HOME} && \
    yum clean all

COPY ./elasticsearch.yml ${ES_HOME}/elasticsearch-8.5.2/config/

USER elasticsearch

EXPOSE 9200 9300

CMD [ "elasticsearch-8.5.2/bin/elasticsearch" ]
```

elasticsearch.yml:

```
path.data: /var/lib/elasticsearch/data
path.logs: /var/lib/elasticsearch/logs
node.name: "netology_test"
network.host: 0.0.0.0
discovery.type: single-node
xpack.security.enabled: false
```

- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий

Ответ: https://hub.docker.com/r/itrevmarc/elasticsearch

- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

```bash
vagrant@server1:~/data/06-db-05-elasticsearch$ curl localhost:9200
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "TE54dpy7Q6SD_RWQn40FMQ",
  "version" : {
    "number" : "8.5.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "a846182fa16b4ebfcc89aa3c11a11fd5adf3de04",
    "build_date" : "2022-11-17T18:56:17.538630285Z",
    "build_snapshot" : false,
    "lucene_version" : "9.4.1",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

```bash
$ curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d '{"settings": \
 {"number_of_shards": 1,"number_of_replicas": 0}}'
$ curl -X PUT localhost:9200/ind-2 -H 'Content-Type: application/json' -d '{"settings": \
{"number_of_shards": 2, "number_of_replicas":1}}'
$ curl -X PUT localhost:9200/ind-3 -H 'Content-Type: application/json' -d '{"settings": \
{"number_of_shards": 4, "number_of_replicas": 2}}'
```

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

```bash
$ curl -X GET localhost:9200/_cat/indices
green  open ind-1 oEVG8fSjRW2nf4qvxdyuLg 1 0 0 0 225b 225b
yellow open ind-3 REWfy2MsS12AvIo-cqFGKQ 4 2 0 0 900b 900b
yellow open ind-2 YOay0i_2SOWvhiqs4CRd0Q 2 1 0 0 450b 450b
```

Получите состояние кластера `elasticsearch`, используя API.

```bash
$ curl -X GET localhost:9200/_cluster/health?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Состояние yellow возможно связано с тем, что негде размещать реплики выделенные шардам, поскольку в кластере
существует только одня нода. Часть шард в состоянии UNASSIGNED.

Удалите все индексы.

```bash
$ curl -X DELETE localhost:9200/ind-1
{"acknowledged":true}
$ curl -X DELETE localhost:9200/ind-2
{"acknowledged":true}
$ curl -X DELETE localhost:9200/ind-3
{"acknowledged":true}
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Dockerfile:
```bash
FROM centos:7

ENV ES_HOME="/var/lib/elasticsearch" 

WORKDIR ${ES_HOME}

RUN yum -y install wget perl-Digest-SHA && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.5.2-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.5.2-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-8.5.2-linux-x86_64.tar.gz.sha512 && \
    rm -f elasticsearch-8.5.2-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.5.2-linux-x86_64.tar.gz && \
    rm -f elasticsearch-8.5.2-linux-x86_64.tar.gz && \
    useradd -m elasticsearch && \
    chown elasticsearch:elasticsearch -R ${ES_HOME} && \
    yum clean all

COPY ./elasticsearch.yml ${ES_HOME}/elasticsearch-8.5.2/config/

USER elasticsearch

RUN mkdir ${ES_HOME}/data ${ES_HOME}/logs ${ES_HOME}/snapshots

EXPOSE 9200 9300

CMD [ "elasticsearch-8.5.2/bin/elasticsearch" ]
```

elasticsearch.yml:
```bash
path.data: /var/lib/elasticsearch/data
path.logs: /var/lib/elasticsearch/logs
path.repo: /var/lib/elasticsearch/snapshots
node.name: "netology_test"
network.host: 0.0.0.0
discovery.type: single-node
xpack.security.enabled: false
```

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

```bash
$ curl -X PUT localhost:9200/_snapshot/netology_backup -H 'Content-Type: application/json' -d '{"type": "fs", "settings": { "location": "/var/lib/elasticsearch/snapshots"}}'
{"acknowledged":true}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```bash
$ curl -X PUT localhost:9200/test -H 'Content-Type: application/json' -d '{"settings": {"number_of_shards": 1, "number_of_replicas": 0}}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}
$ curl localhost:9200/_cat/indices
green open test KVRpi0bVSTyQK9m5cl9kCg 1 0 0 0 225b 225b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

```bash
$ curl -X PUT localhost:9200/_snapshot/netology_backup/%3Cmy_snapshot_%7Bnow%2Fd%7D%3E
{"accepted":true}
```

```bash
[elasticsearch@9b2288312431 snapshots]$ ls -l
total 36
-rw-r--r-- 1 elasticsearch elasticsearch   855 Dec  4 18:25 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Dec  4 18:25 index.latest
drwxr-xr-x 4 elasticsearch elasticsearch  4096 Dec  4 18:25 indices
-rw-r--r-- 1 elasticsearch elasticsearch 18446 Dec  4 18:25 meta-2ELShzJBRKmWULKP7FEoRA.dat
-rw-r--r-- 1 elasticsearch elasticsearch   365 Dec  4 18:25 snap-2ELShzJBRKmWULKP7FEoRA.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```bash
$ curl -X DELETE localhost:9200/test
{"acknowledged":true
$ curl -X PUT localhost:9200/test-2 -H 'Content-Type: application/json' -d '{"settings": {"number_of_shards": 1, "number_of_replicas": 0}}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test-2"}
$ curl localhost:9200/_cat/indices
green open test-2 WIj0ctavTVC_BaD1ITPJ9w 1 0 0 0 225b 225b
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. **Приведите в ответе** запрос к API восстановления и итоговый список индексов.

```bash
$ curl localhost:9200/_snapshot/netology_backup/*?verbose=false
{"snapshots":[{"snapshot":"my_snapshot_2022.12.04","uuid":"2ELShzJBRKmWULKP7FEoRA","repository":"netology_backup","indices":[".geoip_databases","test"],"data_streams":[],"state":"SUCCESS"}],"total":1,"remaining":0}
$ curl -X POST localhost:9200/_snapshot/netology_backup/my_snapshot_2022.12.04/_restore
{"accepted":true}
$ curl localhost:9200/_cat/indices
green open test-2 WIj0ctavTVC_BaD1ITPJ9w 1 0 0 0 225b 225b
green open test   G3rbp8bkSMG5hFjSlJRfLQ 1 0 0 0 225b 225b
```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

