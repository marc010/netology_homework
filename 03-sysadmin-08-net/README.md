# Домашнее задание к занятию "3.8. Компьютерные сети, лекция 3"

1. Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP
```
telnet route-views.routeviews.org
Username: rviews
show ip route x.x.x.x/32
show bgp x.x.x.x/32
```
```bash
>show ip route 46.242.x.x
Routing entry for 46.242.x.x/22
  Known via "bgp 6447", distance 20, metric 0
  Tag 2497, type external
  Last update from 202.232.0.2 7w0d ago
  Routing Descriptor Blocks:
  * 202.232.0.2, from 202.232.0.2, 7w0d ago
      Route metric is 0, traffic share count is 1
      AS Hops 3
      Route tag 2497
      MPLS label: none
```

2. Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.

Добавляем модуль dummy и создаеи 2 dummy интерфейса:
```bash
echo "dummy" >> /etc/module
echo "options dummy numdummies=2" | sudo tee /etc/modprobe.d/dummy.conf
```
Или только для теста:
```bash
sudo modprobe -v dummy numdummies=2
```
Промежуточный результат:
```bash
$ ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             10.0.2.15/24 fe80::a00:27ff:fea2:6bfd/64
eth1             UP             172.28.128.10/24 fe80::a00:27ff:fe1e:8688/64
dummy0           DOWN
dummy1           DOWN
```
Создаем конфиг фойл для dummy0 интерфейса `/etc/netplan/02-dummy0.yaml`, добавим в него статический маршрут:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    dummy0:
      addresses:
        - 192.168.0.1/24
      gateway4: 192.168.0.100
      routes:
        - to: 172.16.0.0/24
          via: 192.168.0.1
```
Результат:
```bash
$ ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             10.0.2.15/24 fe80::a00:27ff:fea2:6bfd/64
eth1             UP             172.28.128.10/24 fe80::a00:27ff:fe1e:8688/64
dummy0           UNKNOWN        192.168.0.1/24 fe80::20c7:68ff:fe99:3c17/64
dummy1           DOWN
$ ip -br route
default via 192.168.0.100 dev dummy0 proto static
default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
10.0.2.2 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
172.16.0.0/24 via 192.168.0.1 dev dummy0 proto static
172.28.128.0/24 dev eth1 proto kernel scope link src 172.28.128.10
192.168.0.0/24 dev dummy0 proto kernel scope link src 192.168.0.1
```

3. Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.

```bash
$ ss -tan
State             Recv-Q            Send-Q                       Local Address:Port                        Peer Address:Port             Process
LISTEN            0                 511                                0.0.0.0:80                               0.0.0.0:*
LISTEN            0                 4096                         127.0.0.53%lo:53                               0.0.0.0:*
LISTEN            0                 128                                0.0.0.0:22                               0.0.0.0:*
ESTAB             0                 0                                10.0.2.15:22                              10.0.2.2:59864
LISTEN            0                 511                                   [::]:80                                  [::]:*
LISTEN            0                 128                                   [::]:22                                  [::]:*
```
* port 80 - web server
* port 22 - ssh

4. Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?

```bash
$ ss -uan
State             Recv-Q            Send-Q                        Local Address:Port                        Peer Address:Port            Process
UNCONN            0                 0                             127.0.0.53%lo:53                               0.0.0.0:*
UNCONN            0                 0                            10.0.2.15%eth0:68                               0.0.0.0:*
```
* port 53 - dns
* port 68 - dhcp

5. Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали. 

![image](https://bitbucket.org/marc101/netology_homework/src/main/03-sysadmin-08-net/pict/Local%20network%20diagram.drawio.png)

