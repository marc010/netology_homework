# Домашнее задание к занятию "3.2. Работа в терминале, лекция 2"

1. Какого типа команда `cd`? Попробуйте объяснить, почему она именно такого типа; опишите ход своих мыслей, если считаете что она могла бы быть другого типа.

```bash
$ type -a cd
 cd is a shell builtin
```
```
    "сd" это всроенная в оболочку команда. Оболочка выполняет всроенную команду напрямую,
без вызова другой программы. Встроенные команды необходимы для реализации
функциональности, которую невозможно или неудобно получить с помощью
отдельных утилит.
```
 
2. Какая альтернатива без pipe команде `grep <some_string> <some_file> | wc -l`? `man grep` поможет в ответе на этот вопрос. Ознакомьтесь с [документом](http://www.smallo.ruhr.de/award.html) о других подобных некорректных вариантах использования pipe.

```bash
$ grep <some_string> <some_file> | wc -l
 <number of lines>
```
```bash
$ grep -c <some_string> <some_file>
 <number of lines>
```

3. Какой процесс с PID `1` является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?

```bash
$ ps -p 1
    PID TTY          TIME CMD
      1 ?        00:00:01 systemd
$ pstree -p
  systemd(1)─┬─ModemManager(912)─┬─{ModemManager}(967)
           │                   └─{ModemManager}(969)
           ├─VBoxService(953)─┬─{VBoxService}(955)
           │                  ├─{VBoxService}(956)
           │                  ├─{VBoxService}(957)
```
 
4. Как будет выглядеть команда, которая перенаправит вывод stderr `ls` на другую сессию терминала?

Первая сессия (pts/0):
```bash
$ w
 18:05:56 up  3:06,  2 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
vagrant  pts/0    10.0.2.2         17:09    0.00s  0.05s  0.00s w
```
Вторая сессия (pts/1):
```bash
$ w
 18:07:55 up  3:08,  2 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
vagrant  pts/0    10.0.2.2         17:09    1:59   0.05s  0.05s -bash
vagrant  pts/1    10.0.2.2         18:04    3.00s  0.00s  0.00s w
```
В превой сессии выполняем команду `ls` результатои которой будет запись в stderr (передадим ей несуществующий каталог):
```bash
$ ls /test 2>/dev/pts/1
```
Результат увидим во второй сессии:
```bash
$ ls: cannot access '/test': No such file or directory
```

5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл? Приведите работающий пример.

```bash
$ cat file
123
qwe
asd
zxc
$ cat file2
cat: file2: No such file or directory
$ cat < file > file2
$ cat file2
123
qwe
asd
zxc
```

6. Получится ли вывести находясь в графическом режиме данные из PTY в какой-либо из эмуляторов TTY? Сможете ли вы наблюдать выводимые данные?

```bash
$ echo "some meassge to tty1" > /dev/tty1
```
Если находится в tty1 (ctrl + alt + f1) можно увидеть:
```bash
$ some meassge to tty1
```

7. Выполните команду `bash 5>&1`. К чему она приведет? Что будет, если вы выполните `echo netology > /proc/$$/fd/5`? Почему так происходит?

Команда `bash 5>&1` создает дескриптор и перенаправляет вывод с него в stdout. Команда `echo netology > /proc/$$/fd/5` выведет `netology` в дескриптор 5, результат можно увидеть в stdout (аналогично: `echo netology >&5`). Работает только в рамках данной сессии.

8. Получится ли в качестве входного потока для pipe использовать только stderr команды, не потеряв при этом отображение stdout на pty? Напоминаем: по умолчанию через pipe передается только stdout команды слева от `|` на stdin команды справа.
Это можно сделать, поменяв стандартные потоки местами через промежуточный новый дескриптор, который вы научились создавать в предыдущем вопросе.

```bash
$ ls /test 5>&2 2>&1 1>&5 | wc -l
1
```
* 5>&2 перенаправление дескриптора 5 в stderr
* 2>&1 перенаправление stderr в stdout
* 1>&5 перенапрваление stdout в дескриптор 5

9. Что выведет команда `cat /proc/$$/environ`? Как еще можно получить аналогичный по содержанию вывод?

`cat /proc/$$/environ` показывает состояние переменных среды на момент запуска процесса bash. Аналогичный результат можно получить при вызове команд: `env`, `printenv`.

10. Используя `man`, опишите что доступно по адресам `/proc/<PID>/cmdline`, `/proc/<PID>/exe`.

`/proc/<PID>/cmdline` - файл, доступный только для чтения. Содержит полный путь до исполняемого файла процесса, только если процесс не является zombie процессом.

`/proc/<PID>/exe` - файл, представляющий собой символическую ссылку, содержащую путь до файла запущенного процесса. Запуск этого файла запустит еще одну копию самого файла. При
попытке открыть ее откроется исполняемый файл.

11. Узнайте, какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью `/proc/cpuinfo`.

```bash
$ grep sse /proc/cpuinfo
flags  : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single fsgsbase avx2 invpcid rdseed clflushopt md_clear flush_l1d arch_capabilities
```
Ответ: sse4_2

12. При открытии нового окна терминала и `vagrant ssh` создается новая сессия и выделяется pty. Это можно подтвердить командой `tty`, которая упоминалась в лекции 3.2. Однако:

```bash
$ ssh localhost 'tty'
not a tty
```

Почитайте, почему так происходит, и как изменить поведение.

```
Возможно это происходит из-за того, что при подключении по ssh вызывается
комодна login и до авторизации не создается псевдотерминал.
```
Поведение команды можно изменить добавив ключ -t в команду ssh:

```bash
$ ssh -t localhost 'tty'
vagrant@localhost's password:
/dev/pts/0
Connection to localhost closed.
```

13. Бывает, что есть необходимость переместить запущенный процесс из одной сессии в другую. Попробуйте сделать это, воспользовавшись `reptyr`. Например, так можно перенести в `screen` процесс, который вы запустили по ошибке в обычной SSH-сессии.

Запускаем в ssh сессии процесс:
```bash
$ htop &
[1] 16405
```

В другой сессии выполняем:
```bash
$ reptyr 16405
```
Запущенный в первой сессии процесс htop отобразиться во второй сессии.

При выполнении столкнулся с проблемой:
```
Unable to attach to pid 16405: Operation not permitted
The kernel denied permission while attaching. If your uid matches
the target's, check the value of /proc/sys/kernel/yama/ptrace_scope.
For more information, see /etc/sysctl.d/10-ptrace.conf
```
Измененил значение kernel.yama.ptrace_scope = 0 в /etc/sysctl.d/10-ptrace.conf 
и выполнил команду `sudo sysctl -p /etc/sysctl.d/10-ptrace.conf`
 
14. `sudo echo string > /root/new_file` не даст выполнить перенаправление под обычным пользователем, так как перенаправлением занимается процесс shell'а, который запущен без `sudo` под вашим пользователем. Для решения данной проблемы можно использовать конструкцию `echo string | sudo tee /root/new_file`. Узнайте что делает команда `tee` и почему в отличие от `sudo echo` команда с `sudo tee` будет работать.

Команда `tee` копирует stdin в stdout и в файл. Поскольку `tee` не является встроенной
в оболочку командой, она запускается отдельным процессом, это позволяет запустить ее от
sudo.