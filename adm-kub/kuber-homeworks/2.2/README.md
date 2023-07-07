# Домашнее задание к занятию «Хранение в K8s. Часть 2»

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs). 
2. [Описание Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
3. [Описание динамического провижининга](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). 
4. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task1
  namespace: netology
  labels:
    busybox: multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      busybox: multitool
  template:
    metadata:
      labels:
        busybox: multitool
    spec:
      containers:
      - name: busybox
        image: busybox:1.36.1
        command: ['sh', '-c', 'while true; do echo Success! >> /output/file.txt; sleep 5; done']
        volumeMounts:
        - name: volume1
          mountPath: /output
      - name: multitool
        image: wbitt/network-multitool:alpine-extra
        env:
        - name: HTTP_PORT
          value: "8080"
        volumeMounts:
        - name: volume1
          mountPath: /input
      volumes:
      - name: volume1
        persistentVolumeClaim:
          claimName: pvc
```

2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.

PV:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv1
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  hostPath:
    path: /data/pv1
```

PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc
  namespace: netology
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 

```bash
$ kubectl create namespace netology
namespace/netology created
```

```bash
$ kubectl get pv
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM          STORAGECLASS   REASON   AGE
pv1    1Gi        RWO            Delete           Bound    netology/pvc                           29s
```

```bash
$ kubectl exec -n netology pods/task1-65df794fc9-7wvxv -c multitool -- cat /input/file.txt
Success!
Success!
Success!
Success!
Success!
Success!
Success!
Success!
Success!
Success!
Success!
```

4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.

```bash
$ kubectl delete -f deployment.yaml 
deployment.apps "task1" deleted
$ kubectl delete -f pvc.yaml 
persistentvolumeclaim "pvc" deleted
$ kubectl get pv
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM          STORAGECLASS   REASON   AGE
pv1    1Gi        RWO            Delete           Failed   netology/pvc                           2m33s
```

После удаления deployment и pvc pv перешел в состояние Failed. Это произошло поскольку значение
`persistentVolumeReclaimPolicy` в описании pv установлен в значение `Delete`, а в качестве `hostPath` значение
`path: /data/pv1`. Кубернетис пытается удалить директорию, но у него нет на это прав, это видно в выводе 
команды `kubectl describe pv`:

```
Warning  VolumeFailedDelete  82s   persistentvolume-controller  host_path deleter only supports /tmp/.+ but received provided /data/pv1
```


5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.

```bash
$ tail -n 3 /data/pv1/file.txt 
Success!
Success!
Success!
```

```bash
$ kubectl delete -f pv.yaml 
persistentvolume "pv1" deleted
$ kubectl get pv
No resources found
```

Если изменить `hostPath` значение на `path: /tmp/data/pv1`, то после удаления pv директория /tmp/data/pv1 будет удалена.

6. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.

```bash
$ microk8s enable community
$ microk8s enable nfs
```

2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.

Deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task2
  labels:
    app: multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: multitool
  template:
    metadata:
      labels:
        app: multitool
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool:alpine-extra
        volumeMounts:
        - name: volume2
          mountPath: /common
      volumes:
      - name: volume2
        persistentVolumeClaim:
          claimName: dynamic-volume-claim
```

PVS:
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: dynamic-volume-claim
spec:
  storageClassName: "nfs"
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

3. Продемонстрировать возможность чтения и записи файла изнутри пода. 

```bash
$ kubectl exec -it task2-5d9dd98bc4-ksr24 -- /bin/bash
bash-5.1# ls
bin                   dev                   home                  mnt                   root                  srv                   usr
certs                 docker-entrypoint.sh  lib                   opt                   run                   sys                   var
common                etc                   media                 proc                  sbin                  tmp
bash-5.1# cd common/
bash-5.1# echo netology > file.txt
bash-5.1# ls
file.txt
bash-5.1# cat file.txt 
netology
```

На машине где установлен microk8s:

```bash
$ cd /var/snap/microk8s/common/nfs-storage/pvc-cc0caa2f-af97-4f8f-a526-8ece7c234e06/
$ ls
file.txt
$ cat file.txt 
netology
```

4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
