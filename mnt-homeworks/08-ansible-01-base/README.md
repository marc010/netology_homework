# Домашнее задание к занятию "1. Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

```bash
$ ansible-playbook -i inventory/test.yml site.yml 

PLAY [Print os facts] ********************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [localhost]

TASK [Print OS] **************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP *******************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
Ответ: 12

2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.

Файл: `./playbook/group_vars/all/examp.yml`:
```
---
  some_fact: "all default fact"
```

3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

```bash
$ docker run -d --rm -it --name centos7 centos:7
$ docker run -d --rm -it --name ubuntu ubuntu:22.04
```

Необходимо установать python в контейнер с ubuntu

4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

```bash
$ ansible-playbook -i inventory/prod.yml site.yml 

PLAY [Print os facts] ********************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] **************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Debian"
}

TASK [Print fact] ************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP *******************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

```bash
$ ansible-playbook -i inventory/prod.yml site.yml 

PLAY [Print os facts] ********************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] **************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Debian"
}

TASK [Print fact] ************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *******************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

```bash
$ ansible-vault encrypt group_vars/deb/examp.yml group_vars/el/examp.yml 
New Vault password: 
Confirm New Vault password: 
Encryption successful
```

8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

```bash
$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] ********************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] **************************************************************************
ok: [ubuntu] => {
    "msg": "Debian"
}
ok: [centos7] => {
    "msg": "CentOS"
}

TASK [Print fact] ************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *******************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

Для просмотра плагинов в разделе connection:
```bash
$ ansible-doc -t connection -l
```
Для работы на `control node` используется плагин: `local`

10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

```
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```

11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

```bash
$ ansible-playbook -i inventory/prod.yml site.yml 

PLAY [Print os facts] ********************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [ubuntu]
ok: [centos7]
ok: [localhost]

TASK [Print OS] **************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Debian"
}

TASK [Print fact] ************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *******************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.

```bash
$ ansible-vault decrypt group_vars/deb/examp.yml group_vars/el/examp     .y
Vault password: 
Decryption successful
```

2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.

```bash
$ ansible-vault encrypt_string
New Vault password: 
Confirm New Vault password: 
Reading plaintext input from stdin. (ctrl-d to end input, twice if your content does not already have a newline)
PaSSw0rd
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          62313032666136666239396232333762323062323934613336623038336634343931646637346364
          6562306638643532636361626632363230643738353136370a373963613833633338303463326138
          65343135386138623966636433346265383839303031626462636331626231663564626661346432
          3632353335653061630a383535303237643666643562366532636461653131623661643737616137
          3563
Encryption successful
```

Файл:
```
---
  some_fact: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          62313032666136666239396232333762323062323934613336623038336634343931646637346364
          6562306638643532636361626632363230643738353136370a373963613833633338303463326138
          65343135386138623966636433346265383839303031626462636331626231663564626661346432
          3632353335653061630a383535303237643666643562366532636461653131623661643737616137
          3563
```

3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.

```bash
$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] ********************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [ubuntu]
ok: [localhost]
ok: [centos7]

TASK [Print OS] **************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Debian"
}

TASK [Print fact] ************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *******************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).

```bash
$ ansible-playbook -i inventory/prod.yml site.yml 

PLAY [Print os facts] ********************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [ubuntu]
ok: [centos7]
ok: [localhost]
ok: [fedora]

TASK [Print OS] **************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Debian"
}
ok: [fedora] => {
    "msg": "Fedora"
}

TASK [Print fact] ************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora] => {
    "msg": "fed default fact"
}

PLAY RECAP *******************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.

```bash
#!/usr/bin/env bash

docker run -d -it --rm --name fedora pycontribs/fedora
docker run -d -it --rm --name ubuntu python
docker run -d -it --rm --name centos7 centos:7

ansible-playbook -i inventory/prod.yml site.yml

docker stop $(docker ps -a -q)
```

6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.