# Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

Разрежённый файл - файл, в котором последовательности нулевых байтов заменены на информацию об этих последовательностях.
Подходят для хранения "больших" файлов, содержащих большие последовательности нулевых байтов (файлы жестких дисков виртуальных машин, торрент файлов и т.п.)

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Файлы, являющиеся жесткой ссылкой на один объект, не могут иметь разные првав доступа и владельца, поскольку жесткая ссылка указывает на inode файла, где содержатся сведения о владельце, правах доступа,
дате создания и модификации.

3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

```bash
$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 43.6M  1 loop /snap/snapd/14978
loop1                       7:1    0 61.9M  1 loop /snap/core20/1328
loop2                       7:2    0 67.2M  1 loop /snap/lxd/21835
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk
sdc                         8:32   0  2.5G  0 disk
```

4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

```bash
$ fdisk /dev/sdb
Command (m for help): p

Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x2e60e22e

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (1-4, default 1):
First sector (2048-5242879, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x2e60e22e

Device     Boot Start     End Sectors Size Id Type
/dev/sdb1        2048 4196351 4194304   2G 83 Linux

Command (m for help): F
Unpartitioned space /dev/sdb: 511 MiB, 535822336 bytes, 1046528 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes

  Start     End Sectors  Size
4196352 5242879 1046528  511M

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (2-4, default 2):
First sector (4196352-5242879, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879):

Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x2e60e22e

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```
Результат:
```bash
$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 43.6M  1 loop /snap/snapd/14978
loop1                       7:1    0 61.9M  1 loop /snap/core20/1328
loop2                       7:2    0 67.2M  1 loop /snap/lxd/21835
loop3                       7:3    0   62M  1 loop /snap/core20/1611
loop4                       7:4    0   47M  1 loop /snap/snapd/16292
loop5                       7:5    0 67.8M  1 loop /snap/lxd/22753
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
└─sdb2                      8:18   0  511M  0 part
sdc                         8:32   0  2.5G  0 disk
```

5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

```bash
$ sfdisk -d /dev/sdb | sfdisk /dev/sdc
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0x2e60e22e.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x2e60e22e

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```
Результат:
```bash
$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 43.6M  1 loop /snap/snapd/14978
loop1                       7:1    0 61.9M  1 loop /snap/core20/1328
loop2                       7:2    0 67.2M  1 loop /snap/lxd/21835
loop3                       7:3    0   62M  1 loop /snap/core20/1611
loop4                       7:4    0   47M  1 loop /snap/snapd/16292
loop5                       7:5    0 67.8M  1 loop /snap/lxd/22753
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
└─sdb2                      8:18   0  511M  0 part
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
└─sdc2                      8:34   0  511M  0 part
```

6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

```bash
$ mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b1,c1}
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 43.6M  1 loop  /snap/snapd/14978
loop1                       7:1    0 61.9M  1 loop  /snap/core20/1328
loop2                       7:2    0 67.2M  1 loop  /snap/lxd/21835
loop3                       7:3    0   62M  1 loop  /snap/core20/1611
loop4                       7:4    0   47M  1 loop  /snap/snapd/16292
loop5                       7:5    0 67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part  /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdb2                      8:18   0  511M  0 part
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdc2                      8:34   0  511M  0 part
```

7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

```bash
$ mdadm --create --verbose /dev/md1 -l 0 -n 2 /dev/sd{b2,c2}
mdadm: chunk size defaults to 512K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 43.6M  1 loop  /snap/snapd/14978
loop1                       7:1    0 61.9M  1 loop  /snap/core20/1328
loop2                       7:2    0 67.2M  1 loop  /snap/lxd/21835
loop3                       7:3    0   62M  1 loop  /snap/core20/1611
loop4                       7:4    0   47M  1 loop  /snap/snapd/16292
loop5                       7:5    0 67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part  /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdb2                      8:18   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdc2                      8:34   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
```

8. Создайте 2 независимых PV на получившихся md-устройствах.

```bash
$ pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
$ pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
```
Результат:
```bash
$ pvdisplay -C
  PV         VG        Fmt  Attr PSize    PFree
  /dev/md0             lvm2 ---    <2.00g   <2.00g
  /dev/md1             lvm2 ---  1018.00m 1018.00m
  /dev/sda3  ubuntu-vg lvm2 a--   <62.50g   31.25g
```

9. Создайте общую volume-group на этих двух PV.

```bash
$ vgcreate vg_test /dev/md0 /dev/md1
  Volume group "vg_test" successfully created
```
Результат:
```bash
$ pvs
  PV         VG        Fmt  Attr PSize    PFree
  /dev/md0   vg_test   lvm2 a--    <2.00g   <2.00g
  /dev/md1   vg_test   lvm2 a--  1016.00m 1016.00m
  /dev/sda3  ubuntu-vg lvm2 a--   <62.50g   31.25g
```

10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

```bash
$ lvcreate -n test -L 100M vg_test /dev/md1
  Logical volume "test" created.
```
Результат:
```bash
lvs
  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ubuntu-lv ubuntu-vg -wi-ao---- <31.25g
  test      vg_test   -wi-a----- 100.00m
```

11. Создайте `mkfs.ext4` ФС на получившемся LV.

```bash
$ mkfs.ext4 /dev/vg_test/test
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```
Результат:
```bash
$ lsblk -f
NAME                 FSTYPE            LABEL     UUID                                   FSAVAIL FSUSE% MOUNTPOINT
loop0                squashfs                                                                 0   100% /snap/snapd/14978
loop1                squashfs                                                                 0   100% /snap/core20/1328
loop2                squashfs                                                                 0   100% /snap/lxd/21835
loop3                squashfs                                                                 0   100% /snap/core20/1611
loop4                squashfs                                                                 0   100% /snap/snapd/16292
loop5                squashfs                                                                 0   100% /snap/lxd/22753
sda
├─sda1
├─sda2               ext4                        1347b25b-64dd-4d97-80ce-90cd82397358      1.3G     7% /boot
└─sda3               LVM2_member                 x7S6t2-at3n-E9kU-cz28-gAH3-QU9H-vyVuNf
  └─ubuntu--vg-ubuntu--lv
                     ext4                        d940a45b-2440-4ece-9c0c-45ced4c52e39     25.4G    12% /
sdb
├─sdb1               linux_raid_member vagrant:0 62afea4b-f92b-7538-d6e1-1e489229a4d1
│ └─md0              LVM2_member                 PxsbSX-E0kW-st0L-5Fxk-wOjw-9pBI-AXDrC7
└─sdb2               linux_raid_member vagrant:1 ae7eb85e-d7d8-a1da-a405-6b26bafadb2c
  └─md1              LVM2_member                 A6xAeQ-vqns-U4IA-Noxy-zxsy-Rg9f-t97K9S
    └─vg_test-test   ext4                        dd994a1a-9ca7-4947-83c2-b63fae9161cf
sdc
├─sdc1               linux_raid_member vagrant:0 62afea4b-f92b-7538-d6e1-1e489229a4d1
│ └─md0              LVM2_member                 PxsbSX-E0kW-st0L-5Fxk-wOjw-9pBI-AXDrC7
└─sdc2               linux_raid_member vagrant:1 ae7eb85e-d7d8-a1da-a405-6b26bafadb2c
  └─md1              LVM2_member                 A6xAeQ-vqns-U4IA-Noxy-zxsy-Rg9f-t97K9S
    └─vg_test-test   ext4                        dd994a1a-9ca7-4947-83c2-b63fae9161cf
```
12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

```bash
$ mount /dev/vg_test/test /tmp/new
```
Результат:
```bash
$ mount | grep '/tmp/new'
/dev/mapper/vg_test-test on /tmp/new type ext4 (rw,relatime,stripe=256)
```

13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

```bash
$ ls /tmp/new
lost+found  test.gz
```

14. Прикрепите вывод `lsblk`.

```bash
 lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 43.6M  1 loop  /snap/snapd/14978
loop1                       7:1    0 61.9M  1 loop  /snap/core20/1328
loop2                       7:2    0 67.2M  1 loop  /snap/lxd/21835
loop3                       7:3    0   62M  1 loop  /snap/core20/1611
loop4                       7:4    0   47M  1 loop  /snap/snapd/16292
loop5                       7:5    0 67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part  /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdb2                      8:18   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
    └─vg_test-test        253:1    0  100M  0 lvm   /tmp/new
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdc2                      8:34   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
    └─vg_test-test        253:1    0  100M  0 lvm   /tmp/new
```

15. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

Результат:
```bash
$ gzip -t ./test.gz | echo $?
0
```

16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

```bash
$ pvmove /dev/md1 /dev/md0
  /dev/md1: Moved: 8.00%
  /dev/md1: Moved: 100.00%
```
Результат:
```bash
$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 43.6M  1 loop  /snap/snapd/14978
loop1                       7:1    0 61.9M  1 loop  /snap/core20/1328
loop2                       7:2    0 67.2M  1 loop  /snap/lxd/21835
loop3                       7:3    0   62M  1 loop  /snap/core20/1611
loop4                       7:4    0   47M  1 loop  /snap/snapd/16292
loop5                       7:5    0 67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1.5G  0 part  /boot
└─sda3                      8:3    0 62.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
│   └─vg_test-test        253:1    0  100M  0 lvm   /tmp/new
└─sdb2                      8:18   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
│   └─vg_test-test        253:1    0  100M  0 lvm   /tmp/new
└─sdc2                      8:34   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
```

17. Сделайте `--fail` на устройство в вашем RAID1 md.

```bash
$  mdadm /dev/md0 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
```
Результат:
```bash
$ mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Tue Aug 23 18:05:11 2022
        Raid Level : raid1
        Array Size : 2094080 (2045.00 MiB 2144.34 MB)
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Tue Aug 23 19:29:06 2022
             State : clean, degraded
    Active Devices : 1
   Working Devices : 1
    Failed Devices : 1
     Spare Devices : 0

Consistency Policy : resync

              Name : vagrant:0  (local to host vagrant)
              UUID : 62afea4b:f92b7538:d6e11e48:9229a4d1
            Events : 19

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       33        1      active sync   /dev/sdc1

       0       8       17        -      faulty   /dev/sdb1

```

18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

```bash
$ dmesg
...
[10949.332695] md/raid1:md0: Disk failure on sdb1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

Результат:
```bash
$ gzip -t ./test.gz | echo $?
0
```

20. Погасите тестовый хост, `vagrant destroy`.

Выполнено.