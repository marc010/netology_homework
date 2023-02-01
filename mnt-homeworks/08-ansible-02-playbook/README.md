# Домашнее задание к занятию "2. Работа с Playbook"

## Подготовка к выполнению

1. (Необязательно) Изучите, что такое [clickhouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [vector](https://www.youtube.com/watch?v=CgEhyffisLY)
2. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

```bash
$ docker run -d -it -p 9000:9000 -p 8123:8123 --rm --name clickhouse-01 centos:7
$ docker run -d -it --rm --name vector-01 centos:7
```

## Основная часть

1. Приготовьте свой собственный inventory файл `prod.yml`.

```
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_connection: docker
vector:
  hosts:
    vector-01:
      ansible_connection: docker
```

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).

```
- name: Install Vector
  hosts: vector
  tasks:
    - name: Get vector distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-1.x86_64.rpm"
        dest: "./vector-{{ vector_version }}-1.x86_64.rpm"
    - name: Install vector clickhouse_packages
      ansible.builtin.yum:
        name:
          - vector-{{ vector_version }}-1.x86_64.rpm
```

3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

```bash
$ ansible-lint site.yml 
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
WARNING  Listing 1 violation(s) that are fatal
command-instead-of-shell: Use shell only when shell functionality is required
site.yml:5 Task/Handler: Start clickhouse service

You can skip specific rules or tags by adding them to your configuration file:
# .ansible-lint
warn_list:  # or 'skip_list' to silence them completely
  - command-instead-of-shell  # Use shell only when shell functionality is required

Finished with 1 failure(s), 0 warning(s) on 1 files.
```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

```bash
$ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] ****************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] *******************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system"]}

PLAY RECAP *******************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0  
```

play прекратил выполнение поскольку он не смог запустить файл на системе которого еще нет.

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

```
$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] ****************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] *******************************************************
changed: [clickhouse-01]

RUNNING HANDLER [Start clickhouse service] ***********************************************
changed: [clickhouse-01]

TASK [Create database] *******************************************************************
changed: [clickhouse-01]

PLAY [Install Vector] ********************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [vector-01]

TASK [Get vector distrib] ****************************************************************
changed: [vector-01]

TASK [Install vector clickhouse_packages] ************************************************
changed: [vector-01]

PLAY RECAP *******************************************************************************
clickhouse-01              : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
vector-01                  : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

```bash
$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] ****************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 0, "group": "root", "item": "clickhouse-common-static", "mode": "0644", "msg": "Request failed", "owner": "root", "response": "HTTP Error 404: Not Found", "size": 246310036, "state": "file", "status_code": 404, "uid": 0, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] *******************************************************
ok: [clickhouse-01]

TASK [Create database] *******************************************************************
ok: [clickhouse-01]

PLAY [Install Vector] ********************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [vector-01]

TASK [Get vector distrib] ****************************************************************
ok: [vector-01]

TASK [Install vector clickhouse_packages] ************************************************
ok: [vector-01]

PLAY RECAP *******************************************************************************
clickhouse-01              : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
vector-01                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

## [PLAYBOOK](./playbook)

---
### Замечания при работе с docker:

* `become: true` не работает в docker поскольку пользователь там уже root
* В centos 7 handlers `ansible.builtin.service` не отработал при запуске clickhouse-server. Я думаю, это сязано с особенностью работы systemd в docker. Использовал `ansible.builtin.shell`
---