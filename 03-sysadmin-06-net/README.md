# Домашнее задание к занятию "3.6. Компьютерные сети, лекция 1"

1. Работа c HTTP через телнет.
- Подключитесь утилитой телнет к сайту stackoverflow.com
`telnet stackoverflow.com 80`
- отправьте HTTP запрос
```bash
GET /questions HTTP/1.0
HOST: stackoverflow.com
[press enter]
[press enter]
```
- В ответе укажите полученный HTTP код, что он означает?

Ответ:

```
HTTP/1.1 301 Moved Permanently
Server: Varnish
Retry-After: 0
Location: https://stackoverflow.com/questions
Content-Length: 0
Accept-Ranges: bytes
Date: Tue, 06 Sep 2022 12:23:07 GMT
Via: 1.1 varnish
Connection: close
X-Served-By: cache-fra19145-FRA
X-Cache: HIT
X-Cache-Hits: 0
X-Timer: S1662466988.790992,VS0,VE0
Strict-Transport-Security: max-age=300
X-DNS-Prefetch-Control: off
```

Код ответа 301 означает, что URI запрашиваемого ресурса был изменён. Произошел редирект: 
`Location: https://stackoverflow.com/questions`

2. Повторите задание 1 в браузере, используя консоль разработчика F12.
- откройте вкладку `Network`
- отправьте запрос http://stackoverflow.com
- найдите первый ответ HTTP сервера, откройте вкладку `Headers`
- укажите в ответе полученный HTTP код.
- проверьте время загрузки страницы, какой запрос обрабатывался дольше всего?
- приложите скриншот консоли браузера в ответ.

HTTP код ответа в браузере:
```
HTTP/1.1 301 Moved Permanently
Connection: close
Content-Length: 0
Server: Varnish
Retry-After: 0
Location: https://stackoverflow.com/
Accept-Ranges: bytes
Date: Tue, 06 Sep 2022 12:32:52 GMT
Via: 1.1 varnish
X-Served-By: cache-fra19146-FRA
X-Cache: HIT
X-Cache-Hits: 0
X-Timer: S1662467572.103274,VS0,VE0
Strict-Transport-Security: max-age=300
X-DNS-Prefetch-Control: off
```

Всего сделано 68 запросов. Загружено 2,94 МБ / 663,05 КБ передано. Загружено за  1,27 с.

3. Какой IP адрес у вас в интернете?

Собственный адрес можно проверить на сайте `whoer.net`. Мой адресЖ 46.242.х.х

4. Какому провайдеру принадлежит ваш IP адрес? Какой автономной системе AS? Воспользуйтесь утилитой `whois`

```bash
$ whois -h whois.radb.net 46.242.x.x
route:          46.242.14.0/23
origin:         AS42610
mnt-by:         NCNET-MNT
created:        2019-10-19T16:59:55Z
last-modified:  2019-10-19T16:59:55Z
source:         RIPE
remarks:        ****************************
remarks:        * THIS OBJECT IS MODIFIED
remarks:        * Please note that all data that is generally regarded as personal
remarks:        * data has been removed from this object.
remarks:        * To view the original object, please query the RIPE Database at:
remarks:        * http://www.ripe.net/whois
remarks:        ****************************
```
 
Провайдер "Ростелеком", AS42610

5. Через какие сети проходит пакет, отправленный с вашего компьютера на адрес 8.8.8.8? Через какие AS? Воспользуйтесь утилитой `traceroute`

```bash
$ sudo traceroute -AnI 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  10.0.2.2 [*]  0.637 ms  0.622 ms  0.619 ms
 2  192.168.0.1 [*]  3.179 ms  3.720 ms  3.718 ms
 3  * * *
 4  77.37.250.221 [AS42610]  5.063 ms  5.338 ms  5.334 ms
 5  77.37.250.249 [AS42610]  5.906 ms  6.372 ms  6.369 ms
 6  72.14.209.81 [AS15169]  7.733 ms  7.631 ms  8.428 ms
 7  108.170.250.129 [AS15169]  8.414 ms  11.940 ms  11.838 ms
 8  * * *
 9  209.85.249.158 [AS15169]  24.093 ms  24.552 ms  24.475 ms
10  216.239.43.20 [AS15169]  25.752 ms  25.747 ms  26.094 ms
11  72.14.236.73 [AS15169]  25.375 ms  25.734 ms  26.447 ms
12  * * *
13  * * *
14  * * *
15  * * *
16  * * *
17  * * *
18  * * *
19  * * *
20  * * *
21  8.8.8.8 [AS15169]  28.735 ms  29.765 ms  29.754 ms
```
 
6. Повторите задание 5 в утилите `mtr`. На каком участке наибольшая задержка - delay?

```bash
                                                 My traceroute  [v0.93]
vagrant (10.0.2.15)                                                                            2022-09-06T13:33:24+0000
Keys:  Help   Display mode   Restart statistics   Order of fields   quit
                                                                               Packets               Pings
 Host                                                                        Loss%   Snt   Last   Avg  Best  Wrst StDev
 1. AS???    10.0.2.2                                                         0.0%    18    0.4   0.3   0.1   0.6   0.2
 2. AS???    192.168.0.1                                                      0.0%    18    3.0   2.5   1.2   6.3   1.3
 3. AS???    192.168.126.204                                                 23.5%    17    4.6   4.8   3.7   9.8   1.6
 4. AS42610  77.37.250.221                                                    0.0%    17    4.9   4.6   3.7   5.3   0.4
 5. AS42610  77.37.250.249                                                    0.0%    17    7.5   5.6   4.5   7.5   1.1
 6. AS15169  72.14.209.81                                                     0.0%    17    7.1  11.2   6.3  43.2   9.5
 7. AS15169  108.170.250.129                                                  0.0%    17    8.6  11.6   7.3  27.5   6.4
 8. AS15169  108.170.250.146                                                 35.3%    17    8.3  11.2   6.6  36.6   8.9
 9. AS15169  209.85.249.158                                                  29.4%    17   24.9  26.4  20.9  44.3   8.6
10. AS15169  216.239.43.20                                                    0.0%    17   24.3  28.6  23.0  72.7  12.2
11. AS15169  72.14.236.73                                                     0.0%    17   23.6  26.0  22.4  52.3   7.1
12. (waiting for reply)
13. (waiting for reply)
14. (waiting for reply)
15. (waiting for reply)
16. (waiting for reply)
17. (waiting for reply)
18. (waiting for reply)
19. (waiting for reply)
20. (waiting for reply)
21. AS15169  8.8.8.8                                                          0.0%    17   22.1  22.6  21.3  27.5   1.7
```

Наибольшая задержка на участке `AS15169  216.239.43.20`

7. Какие DNS сервера отвечают за доменное имя dns.google? Какие A записи? воспользуйтесь утилитой `dig`

```bash
$ dig dns.google

; <<>> DiG 9.16.1-Ubuntu <<>> dns.google
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57094
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;dns.google.                    IN      A

;; ANSWER SECTION:
dns.google.             11      IN      A       8.8.4.4
dns.google.             11      IN      A       8.8.8.8

;; Query time: 4 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Tue Sep 06 13:41:55 UTC 2022
;; MSG SIZE  rcvd: 71
```

```bash
$ nslookup dns.google
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   dns.google
Address: 8.8.8.8
Name:   dns.google
Address: 8.8.4.4
Name:   dns.google
Address: 2001:4860:4860::8888
Name:   dns.google
Address: 2001:4860:4860::8844
```

8. Проверьте PTR записи для IP адресов из задания 7. Какое доменное имя привязано к IP? воспользуйтесь утилитой `dig`

```bash
$ dig +short -x 8.8.4.4
dns.google.
$ dig +short -x 8.8.8.8
dns.google.
```

```bash
$ nslookup 8.8.8.8
8.8.8.8.in-addr.arpa    name = dns.google.

Authoritative answers can be found from:

$ nslookup 8.8.4.4
4.4.8.8.in-addr.arpa    name = dns.google.

Authoritative answers can be found from:
```