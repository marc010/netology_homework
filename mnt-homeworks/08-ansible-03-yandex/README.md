# Домашнее задание к занятию "3. Использование Yandex Cloud"

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.

Ссылка на репозиторий LightHouse: https://github.com/VKCOM/lighthouse

Подготовлено три хоста в Yandex Cloud при помощи [terraform](./terraform)

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.

```
- name: Install Lighthouse
  hosts: lighthouse-01
  handlers:
    - name: Start nginx service
      become: true
      ansible.builtin.service:
        name: nginx
        state: restarted
  tasks: 
    - name: Install required packages
      become: true
      ansible.builtin.yum:
        name:
          - epel-release
          - git
        state: present
      tags:
        - lighthouse
    - name: Install nginx
      become: true
      ansible.builtin.yum:
        name:
          - nginx
        state: present
      tags:
        - lighthouse
    - name: Setup nginx config
      become: true
      ansible.builtin.template:
        src: ./nginx.conf
        dest: /etc/nginx/nginx.conf
      notify: Start nginx service
      tags:
        - lighthouse
    - name: Get lighthouse distrib
      become: true
      ansible.builtin.git:
        repo: 'https://github.com/VKCOM/lighthouse.git'
        dest: /usr/share/nginx/lighthouse/
      notify: Start nginx service
      tags:
        - lighthouse
```

4. Приготовьте свой собственный inventory файл `prod.yml`.

```
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: 
      ansible_user: "centos"
      ansible_ssh_private_key_file: "~/.ssh/id_rsa"
vector:
  hosts:
    vector-01:
      ansible_host: 
      ansible_user: "centos"
      ansible_ssh_private_key_file: "~/.ssh/id_rsa"
lighthouse:
  hosts:
    lighthouse-01:
      ansible_host: 
      ansible_user: "centos"
      ansible_ssh_private_key_file: "~/.ssh/id_rsa"
```

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

```bash
$ ansible-lint site.yml 
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
WARNING  Listing 1 violation(s) that are fatal
git-latest: Git checkouts must contain explicit version
site.yml:94 Task/Handler: Get lighthouse distrib

You can skip specific rules or tags by adding them to your configuration file:
# .ansible-lint
warn_list:  # or 'skip_list' to silence them completely
  - git-latest  # Git checkouts must contain explicit version

Finished with 1 failure(s), 0 warning(s) on 1 files.
```

Добавлен аргумент: `version: master`. Поскольку других тегов не было.

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

```bash
ansible-playbook -i inventory/prod.yml site.yml --check

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

```bash
$ ansible-playbook -i inventory/prod.yml site.yml --diff
...
PLAY RECAP *******************************************************************************
clickhouse-01              : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
lighthouse-01              : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

```bash
$ ansible-playbook -i inventory/prod.yml site.yml --diff
...
PLAY RECAP *******************************************************************************
clickhouse-01              : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
lighthouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

9. Подготовьте [README.md](./playbook/README.md) файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый [playbook](./playbook) выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.
