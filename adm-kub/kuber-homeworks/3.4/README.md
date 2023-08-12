# Домашнее задание к занятию «Обновление приложений»

### Цель задания

Выбрать и настроить стратегию обновления приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Updating a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment).
2. [Статья про стратегии обновлений](https://habr.com/ru/companies/flant/articles/471620/).

-----

### Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор

1. Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
2. Ресурсы, выделенные для приложения, ограничены, и нет возможности их увеличить.
3. Запас по ресурсам в менее загруженный момент времени составляет 20%.
4. Обновление мажорное, новые версии приложения не умеют работать со старыми.
5. Вам нужно объяснить свой выбор стратегии обновления приложения.

#### Ответ:

В данном случае ключевое ограничение в выборе стратегии обновления является то, что обновление мажорное, то есть
новые версии приложения не смогут работать со старыми. Запас по ресурсам также является ограничением в выборе
стратегии. Исходя из условий, единственным форматом обновления является `RECREATE`. При обновлении по стратегии
`RECREATE` будут остановлены запущенные поды, а затем запущены новые.

### Задание 2. Обновить приложение

1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Количество реплик — 5.
2. Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.
3. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.
4. Откатиться после неудачного обновления.

#### Ответ:

Создадим deployment согласно манифесу:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    nginx: multitool
  namespace: netology
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 40%
      maxUnavailable: 40%
  selector:
    matchLabels:
      nginx: multitool
  template:
    metadata:
      labels:
        nginx: multitool
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool:alpine-extra
        env:
        - name: HTTP_PORT
          value: "8080"
        ports:
        - containerPort: 8080
```

Поднимем deployment с версией nginx 1.19:

```bash
$ kubectl apply -f deployment.yaml 
deployment.apps/nginx created
$ kubectl get pods -n netology 
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6fb89d85d7-hfngp   2/2     Running   0          3m54s
nginx-6fb89d85d7-x79vl   2/2     Running   0          3m54s
nginx-6fb89d85d7-lwcw6   2/2     Running   0          3m54s
nginx-6fb89d85d7-wcdff   2/2     Running   0          3m54s
nginx-6fb89d85d7-pcfjz   2/2     Running   0          3m55s
```

Изменим версию nginx на 1.20:

```yaml
...
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
...
```
Поднимем deployment с версией nginx 1.20:

```bash
$ kubectl apply -f deployment.yaml 
deployment.apps/nginx configured
```

И паралельно посмотрим этапы поднятия новый и удаления старых подов:

```bash
$ kubectl get pods -n netology -w
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6fb89d85d7-hfngp   2/2     Running   0          7m52s
nginx-6fb89d85d7-x79vl   2/2     Running   0          7m52s
nginx-6fb89d85d7-lwcw6   2/2     Running   0          7m52s
nginx-6fb89d85d7-wcdff   2/2     Running   0          7m52s
nginx-6fb89d85d7-pcfjz   2/2     Running   0          7m53s
nginx-7bb59fbdc-r4xz9    0/2     Pending   0          0s
nginx-7bb59fbdc-hv4vp    0/2     Pending   0          0s
nginx-7bb59fbdc-r4xz9    0/2     Pending   0          0s
nginx-6fb89d85d7-x79vl   2/2     Terminating   0          8m9s
nginx-6fb89d85d7-wcdff   2/2     Terminating   0          8m9s
nginx-7bb59fbdc-hv4vp    0/2     Pending       0          1s
nginx-7bb59fbdc-q4brs    0/2     Pending       0          0s
nginx-7bb59fbdc-r4xz9    0/2     ContainerCreating   0          2s
nginx-7bb59fbdc-q4brs    0/2     Pending             0          0s
nginx-7bb59fbdc-snmlf    0/2     Pending             0          0s
nginx-7bb59fbdc-snmlf    0/2     Pending             0          0s
nginx-7bb59fbdc-hv4vp    0/2     ContainerCreating   0          3s
nginx-7bb59fbdc-snmlf    0/2     ContainerCreating   0          1s
nginx-7bb59fbdc-q4brs    0/2     ContainerCreating   0          1s
nginx-6fb89d85d7-wcdff   2/2     Terminating         0          8m13s
nginx-6fb89d85d7-x79vl   2/2     Terminating         0          8m13s
nginx-6fb89d85d7-x79vl   0/2     Terminating         0          8m24s
nginx-7bb59fbdc-snmlf    0/2     ContainerCreating   0          14s
nginx-7bb59fbdc-hv4vp    0/2     ContainerCreating   0          17s
nginx-6fb89d85d7-x79vl   0/2     Terminating         0          8m26s
nginx-6fb89d85d7-wcdff   0/2     Terminating         0          8m27s
nginx-6fb89d85d7-x79vl   0/2     Terminating         0          8m27s
nginx-6fb89d85d7-x79vl   0/2     Terminating         0          8m27s
nginx-7bb59fbdc-q4brs    0/2     ContainerCreating   0          17s
nginx-6fb89d85d7-wcdff   0/2     Terminating         0          8m28s
nginx-6fb89d85d7-wcdff   0/2     Terminating         0          8m28s
nginx-6fb89d85d7-wcdff   0/2     Terminating         0          8m29s
nginx-7bb59fbdc-r4xz9    0/2     ContainerCreating   0          20s
nginx-7bb59fbdc-snmlf    2/2     Running             0          31s
nginx-6fb89d85d7-hfngp   2/2     Terminating         0          8m45s
nginx-7bb59fbdc-q4brs    2/2     Running             0          35s
nginx-7bb59fbdc-k48cl    0/2     Pending             0          3s
nginx-7bb59fbdc-hv4vp    2/2     Running             0          42s
nginx-7bb59fbdc-k48cl    0/2     Pending             0          4s
nginx-6fb89d85d7-hfngp   2/2     Terminating         0          8m53s
nginx-7bb59fbdc-k48cl    0/2     ContainerCreating   0          12s
nginx-6fb89d85d7-pcfjz   2/2     Terminating         0          9m
nginx-7bb59fbdc-r4xz9    2/2     Running             0          53s
nginx-6fb89d85d7-lwcw6   2/2     Terminating         0          9m3s
nginx-6fb89d85d7-pcfjz   2/2     Terminating         0          9m4s
nginx-6fb89d85d7-hfngp   0/2     Terminating         0          9m5s
nginx-6fb89d85d7-lwcw6   2/2     Terminating         0          9m5s
nginx-6fb89d85d7-pcfjz   0/2     Terminating         0          9m6s
nginx-7bb59fbdc-k48cl    0/2     ContainerCreating   0          19s
nginx-6fb89d85d7-hfngp   0/2     Terminating         0          9m7s
nginx-6fb89d85d7-pcfjz   0/2     Terminating         0          9m8s
nginx-6fb89d85d7-hfngp   0/2     Terminating         0          9m8s
nginx-6fb89d85d7-hfngp   0/2     Terminating         0          9m8s
nginx-6fb89d85d7-pcfjz   0/2     Terminating         0          9m9s
nginx-6fb89d85d7-pcfjz   0/2     Terminating         0          9m9s
nginx-7bb59fbdc-k48cl    2/2     Running             0          21s
nginx-6fb89d85d7-lwcw6   0/2     Terminating         0          9m8s
nginx-6fb89d85d7-lwcw6   0/2     Terminating         0          9m9s
nginx-6fb89d85d7-lwcw6   0/2     Terminating         0          9m9s
nginx-6fb89d85d7-lwcw6   0/2     Terminating         0          9m9s
```

Изменим версию nginx на 1.28:

```yaml
...
    spec:
      containers:
      - name: nginx
        image: nginx:1.28
...
```
Поднимем deployment с версией nginx 1.28:

```bash
$ kubectl apply -f deployment.yaml 
deployment.apps/nginx configured
```

И паралельно посмотрим этапы поднятия новый и удаления старых подов:

```bash
$ kubectl get pods -n netology -w
NAME                    READY   STATUS    RESTARTS   AGE
nginx-7bb59fbdc-snmlf   2/2     Running   0          4m56s
nginx-7bb59fbdc-q4brs   2/2     Running   0          4m56s
nginx-7bb59fbdc-hv4vp   2/2     Running   0          4m58s
nginx-7bb59fbdc-r4xz9   2/2     Running   0          4m58s
nginx-7bb59fbdc-k48cl   2/2     Running   0          4m20s
nginx-5c4d4c4779-rfkgm   0/2     Pending   0          1s
nginx-7bb59fbdc-r4xz9    2/2     Terminating   0          5m20s
nginx-7bb59fbdc-k48cl    2/2     Terminating   0          4m42s
nginx-5c4d4c4779-2h4xp   0/2     Pending       0          0s
nginx-5c4d4c4779-rfkgm   0/2     Pending       0          1s
nginx-5c4d4c4779-2h4xp   0/2     Pending       0          0s
nginx-5c4d4c4779-rfkgm   0/2     ContainerCreating   0          2s
nginx-5c4d4c4779-2h4xp   0/2     ContainerCreating   0          2s
nginx-5c4d4c4779-nx47z   0/2     Pending             0          0s
nginx-5c4d4c4779-n42bz   0/2     Pending             0          0s
nginx-5c4d4c4779-nx47z   0/2     Pending             0          1s
nginx-5c4d4c4779-n42bz   0/2     Pending             0          0s
nginx-5c4d4c4779-n42bz   0/2     ContainerCreating   0          2s
nginx-5c4d4c4779-nx47z   0/2     ContainerCreating   0          5s
nginx-7bb59fbdc-k48cl    2/2     Terminating         0          4m49s
nginx-7bb59fbdc-r4xz9    2/2     Terminating         0          5m27s
nginx-7bb59fbdc-k48cl    0/2     Terminating         0          4m54s
nginx-7bb59fbdc-k48cl    0/2     Terminating         0          4m55s
nginx-7bb59fbdc-k48cl    0/2     Terminating         0          4m55s
nginx-7bb59fbdc-k48cl    0/2     Terminating         0          4m55s
nginx-7bb59fbdc-r4xz9    0/2     Terminating         0          5m33s
nginx-5c4d4c4779-2h4xp   0/2     ContainerCreating   0          14s
nginx-7bb59fbdc-r4xz9    0/2     Terminating         0          5m35s
nginx-7bb59fbdc-r4xz9    0/2     Terminating         0          5m37s
nginx-5c4d4c4779-rfkgm   0/2     ContainerCreating   0          18s
nginx-7bb59fbdc-r4xz9    0/2     Terminating         0          5m38s
nginx-5c4d4c4779-n42bz   0/2     ContainerCreating   0          17s
nginx-5c4d4c4779-nx47z   0/2     ContainerCreating   0          21s
nginx-5c4d4c4779-2h4xp   1/2     ErrImagePull        0          30s
nginx-5c4d4c4779-rfkgm   1/2     ErrImagePull        0          32s
nginx-5c4d4c4779-2h4xp   1/2     ImagePullBackOff    0          31s
nginx-5c4d4c4779-rfkgm   1/2     ImagePullBackOff    0          33s
nginx-5c4d4c4779-n42bz   1/2     ErrImagePull        0          29s
nginx-5c4d4c4779-n42bz   1/2     ImagePullBackOff    0          30s
nginx-5c4d4c4779-nx47z   1/2     ErrImagePull        0          34s
nginx-5c4d4c4779-nx47z   1/2     ImagePullBackOff    0          35s
nginx-5c4d4c4779-rfkgm   1/2     ErrImagePull        0          58s
nginx-5c4d4c4779-n42bz   1/2     ErrImagePull        0          60s
nginx-5c4d4c4779-nx47z   1/2     ErrImagePull        0          65s
nginx-5c4d4c4779-2h4xp   1/2     ErrImagePull        0          67s
nginx-5c4d4c4779-rfkgm   1/2     ImagePullBackOff    0          71s
nginx-5c4d4c4779-n42bz   1/2     ImagePullBackOff    0          75s
nginx-5c4d4c4779-nx47z   1/2     ImagePullBackOff    0          76s
nginx-5c4d4c4779-2h4xp   1/2     ImagePullBackOff    0          81s
nginx-5c4d4c4779-rfkgm   1/2     ErrImagePull        0          88s
nginx-5c4d4c4779-nx47z   1/2     ErrImagePull        0          90s
nginx-5c4d4c4779-n42bz   1/2     ErrImagePull        0          97s
nginx-5c4d4c4779-rfkgm   1/2     ImagePullBackOff    0          101s
nginx-5c4d4c4779-2h4xp   1/2     ErrImagePull        0          101s
nginx-5c4d4c4779-nx47z   1/2     ImagePullBackOff    0          101s
nginx-5c4d4c4779-2h4xp   1/2     ImagePullBackOff    0          115s
nginx-5c4d4c4779-n42bz   1/2     ImagePullBackOff    0          113s
nginx-5c4d4c4779-rfkgm   1/2     ErrImagePull        0          2m20s
```

Видно что возникла проблема при обновлении, связанная с отсутствием nginx 1.28. Кубернетес остановил
обновление приложений. Можем посмотеть историю обновлений и вернуться на предыдущую версию:

```bash
$ kubectl rollout history deployment nginx -n netology 
deployment.apps/nginx 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>
```

Вернемся на предыдующую версию:

```bash
$ kubectl rollout -n netology undo deployment nginx --to-revision 2
deployment.apps/nginx rolled back
$ kubectl get pods -n netology 
NAME                    READY   STATUS    RESTARTS   AGE
nginx-7bb59fbdc-snmlf   2/2     Running   0          16m
nginx-7bb59fbdc-q4brs   2/2     Running   0          16m
nginx-7bb59fbdc-hv4vp   2/2     Running   0          16m
nginx-7bb59fbdc-qpfp9   2/2     Running   0          29s
nginx-7bb59fbdc-kfc6n   2/2     Running   0          29s
```

## Дополнительные задания — со звёздочкой*

Задания дополнительные, необязательные к выполнению, они не повлияют на получение зачёта по домашнему заданию. **Но мы настоятельно рекомендуем вам выполнять все задания со звёздочкой.** Это поможет лучше разобраться в материале.   

### Задание 3*. Создать Canary deployment

1. Создать два deployment'а приложения nginx.
2. При помощи разных ConfigMap сделать две версии приложения — веб-страницы.
3. С помощью ingress создать канареечный деплоймент, чтобы можно было часть трафика перебросить на разные версии приложения.

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
