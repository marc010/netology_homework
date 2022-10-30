# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной  программой, это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам `bash` при старте. Вам нужно найти тот единственный, который относится именно к `cd`.

```bash
$ strace /bin/bash -c "cd /tmp" 2>&1 | less
```
Ответ:
```
...
chdir("/tmp")
...
```

2. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:
    ```bash
    vagrant@netology1:~$ file /dev/tty
    /dev/tty: character special (5/0)
    vagrant@netology1:~$ file /dev/sda
    /dev/sda: block special (8/0)
    vagrant@netology1:~$ file /bin/bash
    /bin/bash: ELF 64-bit LSB shared object, x86-64
    ```
    Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.

Ответ:

```bash
$ strace file <some_file> 2>&1 | less
```
```
...
stat("/home/vagrant/.magic.mgc", 0x7ffe89a49b40) = -1 ENOENT (No such file or directory)
stat("/home/vagrant/.magic", 0x7ffe89a49b40) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
stat("/etc/magic", {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
read(3, "# Magic local data for file(1) c"..., 4096) = 111
read(3, "", 4096)                       = 0
close(3)                                = 0
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
...
```
Команда  `file` пытается обратиться к файлам `/home/vagrant/.magic.mgc`, 
`/home/vagrant/.magic`, `/etc/magic.mgc`, `/etc/magic`, `/usr/share/misc/magic.mgc`. 
В моем случае чуществует два файла: `/etc/magic` и `/usr/share/misc/magic.mgc`.
В файле `/etc/magic` данных для `file` не было. А вот файл `/usr/share/misc/magic.mgc`, который 
является ссылкой на `/lib/file/magic.mgc`, команда файл нашла свою БД.

```bash
$ file /lib/file/magic.mgc
/lib/file/magic.mgc: magic binary file for file(1) cmd (version 14) (little endian)
```
 
3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

Для примера воспользуемся .swp файлом, который появляется при редактировании файла в
vim. Откроем в vim файл testfile. Пока идет редактирование файла testfile, булет 
создан временный файл testfile.swp. Удалим файл testfile.swp. 

```bash
$ lsof | grep deleted
vim    16930    vagrant    3u      REG 253,0    12288    1311532 /home/vagrant/test/.testfile.swp (deleted)
```
```bash
$  echo '' >/proc/16930/fd/3
```
16930 - PID; 3 - дескриптор удаленного файла. Даннае взяты из вывода lsof.

4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?

Зомби-процессы не занимают ресурсы в ОС, поскольку они уже завершились, но они
еше присутствуют в списке процессов.
 
5. В iovisor BCC есть утилита `opensnoop`:
    ```bash
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
    /usr/sbin/opensnoop-bpfcc
    ```
    На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для Ubuntu 20.04. Дополнительные [сведения по установке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).

man opensnoop:
```
 Trace all open() syscalls, for 10 seconds only:
              # opensnoop -d 10
```
Ответ:

```bash
$ sudo opensnoop-bpfcc -d 1
PID    COMM               FD ERR PATH
354    systemd-journal    32   0 /proc/18264/comm
354    systemd-journal    32   0 /proc/18264/cmdline
354    systemd-journal    32   0 /proc/18264/status
354    systemd-journal    32   0 /proc/18264/attr/current
354    systemd-journal    32   0 /proc/18264/sessionid
354    systemd-journal    32   0 /proc/18264/loginuid
354    systemd-journal    32   0 /proc/18264/cgroup
354    systemd-journal    -1   2 /run/systemd/units/log-extra-fields:session-41.scope
354    systemd-journal    -1   2 /run/log/journal/10ac0529b1ef4e1c85f504f698893be7/system.journal
```

6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.

Ответ:
```bash
$ strace uname -a 2>&1
...
uname({sysname="Linux", nodename="ubuntu", ...}) = 0
...
```


```bash
$ sudo apt install manpages-dev
$ man 2 uname
...
Part of the utsname information is also accessible via /proc/sys/kernel/{ostype,  hostname,  osrelease,  ver‐
       sion, domainname}.
...
```
 
7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
    ```bash
    root@netology1:~# test -d /tmp/some_dir; echo Hi
    Hi
    root@netology1:~# test -d /tmp/some_dir && echo Hi
    root@netology1:~#
    ```
    Есть ли смысл использовать в bash `&&`, если применить `set -e`?

Ответ: 

; - выполняет последовательно каждую следующую команду, как только завершится предыдущая;

&& - выполнить первую команду, а вторую выполнять только если первая завершится успешно;

`set -e` указывает оболочке выйти, еслм команда возвращает ненулевой статус выхода. 
Использование && и `set -e` совмесно не имеет смысла, поскольку они обе не выполнят 
полную последовательность команд, если одна из них завершилась с ошибкой.
 
8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?

* -e - прервет выполнение сценария при ошибке в какой-либо команде
* -u - прервет выполнение при подстановке не существующей переменной и выдаст сообщение об ошибке
* -x - будет выдавать результат команды после каждого выполнения в сценарии
* -o pipefail  - выдаст результат выполнения последней команды в случае если он будет не нулевой

`set -euxo pipefail` полезно использовать при написании скриптов, поскольку она поможет
в отладке и покажет информацию об ошибках, которые могут произойти при выполнении сценария.
 
9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

man ps:
```
...
PROCESS STATE CODES:
       Here are the different values that the s, stat and state output specifiers (header "STAT" or "S") will
       display to describe the state of a process:

               D    uninterruptible sleep (usually IO)
               I    Idle kernel thread
               R    running or runnable (on run queue)
               S    interruptible sleep (waiting for an event to complete)
               T    stopped by job control signal
               t    stopped by debugger during the tracing
               W    paging (not valid since the 2.6.xx kernel)
               X    dead (should never be seen)
               Z    defunct ("zombie") process, terminated but not reaped by its parent

       For BSD formats and when the stat keyword is used, additional characters may be displayed:

               <    high-priority (not nice to other users)
               N    low-priority (nice to other users)
               L    has pages locked into memory (for real-time and custom IO)
               s    is a session leader
               l    is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)
               +    is in the foreground process group
...
```

```bash
$ ps -eo stat | grep -c D; ps -eo stat | grep -c I; ps -eo stat | grep -c R; ps -eo stat | grep -c S; ps -eo stat | grep -c T; ps -eo stat | grep -c t; ps -eo stat | grep -c W;ps -eo stat | grep -c X; ps -eo stat | grep -c Z;
0
46
1
62
1
0
0
0
0
```

Больше всего процессов с кодом S (процесс ожидает, спит меньше 20 секунд) и кодои I (процесс бездействует, спит больше 20 секунд)