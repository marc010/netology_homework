# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ                                                                                                               |
| ------------- |---------------------------------------------------------------------------------------------------------------------|
| Какое значение будет присвоено переменной `c`?  | При попытке сложить число `int` и строку `str` возникает ошибка TypeError.                                          |
| Как получить для переменной `c` значение 12?  | Если привести переменную `a` к строковому типу (a = '1' or a = str(a), то конкатенация строк отработает без ошибок) |
| Как получить для переменной `c` значение 3?  | Если привести переменную `b` к числовому типу (b = 2 or b = int(b), результат арифметической операции будет ожидам  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

bash_command = ["cd ./", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
```

### Вывод скрипта при запуске при тестировании:
```
.gitignore
01-intro-01/task2/task2.md
02-git-04-tools/README.md
03-sysadmin-01-terminal/README.md
03-sysadmin-02-terminal/README.md
03-sysadmin-03-os/README.md
03-sysadmin-04-os/README.md
03-sysadmin-05-fs/README.md
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import subprocess
import sys

try:
    git_path = sys.argv[1]
except IndexError:
    git_path = "./"

print("--info-- Path is: ", git_path)

if os.path.exists(git_path):
    # print("--info-- Path exists")
    r = subprocess.Popen(["git", "-C", git_path, "status", "--porcelain"], stderr=subprocess.DEVNULL, stdout=subprocess.PIPE)
    result_os = r.communicate()
    rc = r.returncode
    if rc == 0:
        print("--info-- This directory is a git repo!")
        result_os = result_os[0].decode()
        for result in result_os.split('\n'):
            if result.find('M') != -1:
                prepare_result = result.replace(' M ', '')
                print(prepare_result)
    else:
        print("--info-- This directory is not a git repo!")

else:
    print("--info-- Path doesn't exist")
```

### Вывод скрипта при запуске при тестировании:
```
--info-- Path is:  /media/marc/Storage/Study/Netology/homeworks/netology_homework
--info-- This directory is a git repo!
.gitignore
01-intro-01/task2/task2.md
02-git-04-tools/README.md
03-sysadmin-01-terminal/README.md
03-sysadmin-02-terminal/README.md
03-sysadmin-03-os/README.md
03-sysadmin-04-os/README.md
03-sysadmin-05-fs/README.md
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import time

server_names = {"drive.google.com": "", "mail.google.com": "", "google.com": ""}

# Первоначальное заполнение
for key in server_names.keys():
    try:
        ip = socket.gethostbyname(key)
        server_names[key] = ip
    except Exception:
        print(f"[!] Error Name or service not known: {key}")
        server_names[key] = "0.0.0.0"

while True:
    for key in server_names.keys():
        try:
            ip = socket.gethostbyname(key)
            if server_names[key] == ip:
                print(key, '-', ip)
            else:
                print(f"[ERROR] {key} IP mismatch: {server_names[key]} {ip}")
                print(key, '-', ip)
        except Exception:
            print(f"[!] Error Name or service not known: {key}")
            server_names[key] = "0.0.0.0"
    print("__________________________________________")
    time.sleep(2)
```

### Вывод скрипта при запуске при тестировании:
```
drive.google.com - 173.194.73.194
[ERROR] mail.google.com IP mismatch: 74.125.131.83 74.125.131.17
mail.google.com - 74.125.131.17
[ERROR] google.com IP mismatch: 108.177.14.139 108.177.14.113
google.com - 108.177.14.113
__________________________________________
drive.google.com - 173.194.73.194
mail.google.com - 74.125.131.83
[ERROR] google.com IP mismatch: 108.177.14.139 108.177.14.138
google.com - 108.177.14.138
__________________________________________
drive.google.com - 173.194.73.194
mail.google.com - 74.125.131.83
[ERROR] google.com IP mismatch: 108.177.14.139 108.177.14.102
google.com - 108.177.14.102
__________________________________________
drive.google.com - 173.194.73.194
[ERROR] mail.google.com IP mismatch: 74.125.131.83 74.125.131.17
mail.google.com - 74.125.131.17
[ERROR] google.com IP mismatch: 108.177.14.139 108.177.14.138
google.com - 108.177.14.138
__________________________________________
```
