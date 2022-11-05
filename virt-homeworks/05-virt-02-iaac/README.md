
# Домашнее задание к занятию "2. Применение принципов IaaC в работе с виртуальными машинами"

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
```
* Скорость. IaaC позволяет быстрее конфигурировать инфраструктуру;
* Масштабируемость. Описание с помощью кода требуемое состояние инфраструктуры;
* Стабильность. Развертывание инфраструктуры с помощью Iaac повторяемы и предотвращают проблемы во время
выполнения, вызванных дрейфом конфигурации;
* IaaC позволяет документировать, регистрировать и отслеживать каждое изменение конфигурации вашего сервера.
При использовании версионирования;
* Восстановление в аварийных ситуациях;
```
- Какой из принципов IaaC является основополагающим?
```
Идемпотентность является основополагающим принципом IaaC.
Идемпотентность - это свойство объекта или операции, при повторном выполнении которой,
мы получаем результат идентичный предыдущему и всем последующим выполнениям.
```

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
```
* Нет необходимости в установке агентов на целевые хосты. Подключается по ssh;
* Оповещает если не удалось доставить конфигурацию на сервер;
* Его playbooks понятны и легко читаемы, даже без особых знаний;
```
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?
```
На мой взгля метод "push" более надежный, посколку управление конфигурацией происходит централизованно.
```
## Задача 3

Установить на личный компьютер:

- VirtualBox

![virtualbox](media/virtualbox.png)

- Vagrant
```bash
$ vagrant --version
Vagrant 2.2.19
```
- Ansible
```bash
$ ansible --version
ansible 2.10.8
  config file = None
  configured module search path = ['/home/marc/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.10.6 (main, Nov  2 2022, 18:53:38) [GCC 11.3.0]
```

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```

1. Vagrantfile:
```ISO = "bento/ubuntu"
NET = "192.168.56."
DOMAIN = ".netology"
HOST_PREFIX = "server"
INVENTORY_PATH = "./ansible/inventory"

servers = [
  {
    :hostname => HOST_PREFIX + "1" + DOMAIN,
    :ip => NET + "11",
    :ssh_host => "20011",
    :ssh_vm => "22",
    :ram => 1024,
    :core => 1
  }
]

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = ISO
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.network :forwarded_port, guest: machine[:ssh_vm], host: machine[:ssh_host]
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.customize ["modifyvm", :id, "--cpus", machine[:core]]
        vb.name = machine[:hostname]
      end
      node.vm.provision "ansible" do |setup|
        setup.inventory_path = INVENTORY_PATH
        setup.playbook = "./ansible/provision.yml"
        setup.become = true
        setup.extra_vars = { ansible_user: 'vagrant' }
      end
    end
  end
end
```
2. Ansible.cfg

```
[defaults]
inventory=./inventory
deprecation_warnings=False
command_warnings=False
ansible_port=22
interpreter_python=/usr/bin/python3
```

3. inventory file:

```
[nodes:children]
manager

[manager]
server1.netology ansible_host=127.0.0.1 ansible_port=20011 ansible_user=vagrant
```

4. provision file:
```
---

  - hosts: nodes
    become: yes
    become_user: root
    remote_user: vagrant

    tasks:
      - name: Create directory for ssh-keys
        file: state=directory mode=0700 dest=/root/.ssh/

      - name: Adding rsa-key in /root/.ssh/authorized_keys
        copy: src=~/.ssh/id_rsa_vagrant.pub dest=/root/.ssh/authorized_keys owner=root mode=0600
        ignore_errors: yes

      - name: Checking DNS
        command: host -t A google.com

      - name: Installing tools
        apt: >
          package={{ item }}
          state=present
          update_cache=yes
        with_items:
          - git
          - curl

      - name: Installing docker
        shell: curl -fsSL get.docker.com -o get-docker.sh && chmod +x get-docker.sh && ./get-docker.sh

      - name: Add the current user to docker group
        user: name=vagrant append=yes groups=docker
```

Результат:

```bash
$ vagrant ssh
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-110-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sat 05 Nov 2022 01:38:10 PM UTC

  System load:  0.08               Users logged in:          0
  Usage of /:   13.1% of 30.63GB   IPv4 address for docker0: 172.17.0.1
  Memory usage: 23%                IPv4 address for eth0:    10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1:    192.168.56.11
  Processes:    119


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Sat Nov  5 13:35:40 2022 from 10.0.2.2
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
vagrant@server1:~$ 

```