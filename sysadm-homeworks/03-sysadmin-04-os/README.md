# Домашнее задание к занятию "3.4. Операционные системы, лекция 2"

1. На лекции мы познакомились с [node_exporter](https://github.com/prometheus/node_exporter/releases). В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой [unit-файл](https://www.freedesktop.org/software/systemd/man/systemd.service.html) для node_exporter:

    * поместите его в автозагрузку,
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`),
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.

Установка node_exporter:
```bash
$ wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0-rc.0/node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
$ tar xvzf node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
$ cp /home/vagrant/node_exporter/node_exporter-1.4.0-rc.0.linux-amd64/node_exporter /usr/bin/node_exporter 
```
Создание unit-файла:
```bash
$ cd /etc/systemd/system
$ touch node_exporter.service
```
Содержимое:
```
[Unit]
Description=Node Exporter Service

[Service]
EnvironmentFile=/etc/default/node_exporter
ExecStart=/usr/bin/node_exporter $EXTRA_OPTS

[Install]
WantedBy=multi-user.target
Alias=node_exporter.service
```
Создание файла с опциями:
```bash
$ echo 'EXTRA_OPTS="--log.level=info"' >/etc/defau0lt/node_exporter
```
Добавление в автозагрузку:
```bash
$ sudo systemctl enable node_exporter
```

```bash
$ sudo systemctl start node_exporter
$ sudo systemctl status node_exporter
● node_exporter.service - Node Exporter Service
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2022-08-19 20:06:18 UTC; 2s ago
   Main PID: 1306 (node_exporter)
      Tasks: 4 (limit: 1066)
     Memory: 2.3M
     CGroup: /system.slice/node_exporter.service
             └─1306 /usr/bin/node_exporter

Aug 19 20:06:18 ubuntu node_exporter[1306]: ts=2022-08-19T20:06:18.933Z caller=node_exporter.go:115 level=info collecto>
Aug 19 20:06:18 ubuntu node_exporter[1306]: ts=2022-08-19T20:06:18.933Z caller=node_exporter.go:115 level=info collecto>
Aug 19 20:06:18 ubuntu node_exporter[1306]: ts=2022-08-19T20:06:18.933Z caller=node_exporter.go:115 level=info collecto>
Aug 19 20:06:18 ubuntu node_exporter[1306]: ts=2022-08-19T20:06:18.933Z caller=node_exporter.go:115 level=info collecto>
Aug 19 20:06:18 ubuntu node_exporter[1306]: ts=2022-08-19T20:06:18.933Z caller=node_exporter.go:115 level=info collecto>
Aug 19 20:06:18 ubuntu node_exporter[1306]: ts=2022-08-19T20:06:18.933Z caller=node_exporter.go:115 level=info collecto>
Aug 19 20:06:18 ubuntu node_exporter[1306]: ts=2022-08-19T20:06:18.933Z caller=node_exporter.go:115 level=info collecto>
Aug 19 20:06:18 ubuntu node_exporter[1306]: ts=2022-08-19T20:06:18.933Z caller=node_exporter.go:115 level=info collecto>
Aug 19 20:06:18 ubuntu node_exporter[1306]: ts=2022-08-19T20:06:18.933Z caller=node_exporter.go:199 level=info msg="Lis>
Aug 19 20:06:18 ubuntu node_exporter[1306]: ts=2022-08-19T20:06:18.933Z caller=tls_config.go:195 level=info msg="TLS is

```


2. Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.

CPU:
```
node_cpu_seconds_total{cpu="0",mode="system"}
node_cpu_seconds_total{cpu="0",mode="user"}
node_schedstat_running_seconds_total{cpu="0"}
process_cpu_seconds_total
```
Memory:
```
node_memory_MemTotal_bytes
node_memory_MemFree_bytes
```
Disk:
```
node_disk_device_mapper_info{device="dm-0",lv_layer="",lv_name="ubuntu-lv",name="ubuntu--vg-ubuntu--lv",uuid="LVM-4HbbNBkISHfXeQqzbVXeNdAt34cCUUuJmJ8K7eF4uwo8Sxiwt0JfLQDpohE7lSU1",vg_name="ubuntu-vg"}
node_disk_io_time_seconds_total{device="sda"}
node_disk_write_time_seconds_total{device="sda"}
node_disk_read_time_seconds_total{device="sda"}
```
Network:
```
node_network_receive_bytes_total{device="eth0"}
node_network_transmit_bytes_total{device="eth0"}
```

3. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). После успешной установки:
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`,
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:

    ```bash
    config.vm.network "forwarded_port", guest: 19999, host: 19999
    ```

    После успешной перезагрузки в браузере *на своем ПК* (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.

Выполнено

4. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?

```bash
$ dmesg | grep virtual
[    0.002051] CPU MTRRs all blank - virtualized system.
[    0.055027] Booting paravirtualized kernel on KVM
[    6.346735] systemd[1]: Detected virtualization oracle.
```

5. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?

```bash
$ sysctl fs.nr_open
fs.nr_open = 1048576
```
Параметр `fs.nr_open` показывает максимальное число открытых файловых дескрипторов в системе. Это значение
кратно 1024.

"Мягкий" лимит
```bash
$ ulimit -Sn
1024
```
"Жесткий" лимит
```bash
$ ulimit -Hn
1048576
```

6. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.

```bash
# tmux
# unshare --fork --pid --mount-proc sleep 1h &
# ps -fe
...
root        3550  0.0  0.0   5480   580 pts/2    S    14:57   0:00 unshare --fork --pid --mount-proc sleep 1h
root        3551  0.0  0.0   5476   580 pts/2    S    14:57   0:00 sleep 1h
root        3553  0.0  0.3   8888  3284 pts/2    R+   14:58   0:00 ps -fe
# nsenter --target 3551 --pid --mount
# ps -fe
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 14:57 pts/2    00:00:00 sleep 1h
root           2       0  0 14:59 pts/2    00:00:00 -bash
root          13       2  0 14:59 pts/2    00:00:00 ps -fe
```

7. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?

`:(){ :|:& };:` 
Более наглядно:
```bash
:() {
    : | : &
    };
:
```
Это функция, которая запускает саму себя бесконечное количество раз, каждый раз порождая новый процесс.

Вывод dmesg:
```bash
$ dmesg
...
[ 7880.189107] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-7.scope
```
Максимальное количество пользовательских процессов:
```bash
$ uname -u
3554
```
Изменить максимальное количество пользовательских процессов можно следующей командой:
`ulimit -u <max-pid-count>`

