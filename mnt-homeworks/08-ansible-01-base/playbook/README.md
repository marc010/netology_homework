# Самоконтроль выполненения задания

1. Где расположен файл с `some_fact` из второго пункта задания?

Ответ: `./playbook/group_vars/all/examp.yml`

2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

Ответ: `ansible-playbook -i inventory/test.yml site.ym`

3. Какой командой можно зашифровать файл?

Ответ: `ansible-vault encrypt <file_path>`

4. Какой командой можно расшифровать файл?

Ответ: `ansible-vault decrypt <file_path>`

5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

Ответ: `ansible-vault view <file_path>`

6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

Ответ: `ansible-playbook -i inventory/test.yml site.ym --ask-vault-pass`

7. Как называется модуль подключения к host на windows?

Ответ: 
```
psrp                           Run tasks over Microsoft PowerShell Remoting Protocol                     
winrm                          Run tasks over Microsoft's WinRM 
```

8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

Ответ: 
```bash
$ ansible-doc -t connection  ssh
```

9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

Ответ:
```
...
- remote_user
        User name with which to login to the remote server, normally
        set by the remote_user keyword.
        If no user is supplied, Ansible will let the ssh client binary
        choose the user as it normally
        [Default: (null)]
        set_via:
          env:
          - name: ANSIBLE_REMOTE_USER
          ini:
          - key: remote_user
            section: defaults
          vars:
          - name: ansible_user
          - name: ansible_ssh_user
...
```