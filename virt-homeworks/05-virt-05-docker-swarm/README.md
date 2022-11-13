# Домашнее задание к занятию "5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
```
* replication означает, что указанное пользователем количество контейнеров для данного сервиса будет
запущено на всех доступных нодах;
* global означает, что данный сервис будет запущен только в одном экземпляре на всех доступных нодах;
```
- Какой алгоритм выбора лидера используется в Docker Swarm кластере?
```
Для выбора лидера в Docker Swarm кластере используется алгоритм RAFT
```
- Что такое Overlay Network?
```
Overlay Network использует технологию vxlan, которая инкапсулирует L2 кадры в L4 пакеты. 
При помощи этого действия Docker создает виртуальные сети поверх существующих связей
между хостами.
```

## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:

```bash
# docker node ls
ID                            HOSTNAME                          STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
v83w0ipnhwp8oinpy6ol8wsi8 *   manager-01.ru-central1.internal   Ready     Active         Leader           20.10.21
yfsn799evd8opqmjy060mtgsj     manager-02.ru-central1.internal   Ready     Active         Reachable        20.10.21
kedldvhpnujwqy63rm5tm8hqy     manager-03.ru-central1.internal   Ready     Active         Reachable        20.10.21
c5z56zuvmynu50qixnpcx30yv     worker-01.ru-central1.internal    Ready     Active                          20.10.21
tppgbe03rxr056y9xjb17l21p     worker-02.ru-central1.internal    Ready     Active                          20.10.21
r36cjcj36p0udmb3rp6k3uqr3     worker-03.ru-central1.internal    Ready     Active                          20.10.21
```

## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```bash
# docker stack ls
NAME         SERVICES   ORCHESTRATOR
monitoring   8          Swarm
[root@manager-01 monitoring]# docker service ls
ID             NAME                          MODE         REPLICAS   IMAGE                                          PORTS
j9j5i28fh8bq   monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0    
q5lbi73insd3   monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
ek7lhrl9wejc   monitoring_cadvisor           global       6/6        google/cadvisor:latest                         
0dnj32tspq61   monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest                      
curp6wnf8aoi   monitoring_grafana            replicated   0/1        stefanprodan/swarmprom-grafana:5.3.4           
sc9spdm9xb6q   monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0   
fofbxsuag2ya   monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0       
pygtugnqv24m   monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0 
```