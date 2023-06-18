# Домашнее задание к занятию «Запуск приложений в K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) Init-контейнеров.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.

Проблема возникает поскольку оба контейнера занимают один и тот же порт. Необходимо переопределить порт у контейнера
multitool, это можно сделать через переменные окружения.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task1
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
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

```bash
$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
task1-65958d99b4-khrgl   2/2     Running   0          48s
```

2. После запуска увеличить количество реплик работающего приложения до 2.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
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

```bash
$ kubectl apply -f task1.yaml 
deployment.apps/task1 configured
$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
task1-65958d99b4-khrgl   2/2     Running   0          3m16s
task1-65958d99b4-2b8mk   2/2     Running   0          3s
```

3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: task1-svc
spec:
  selector:
    app: nginx
  ports:
  - name: nginx
    port: 80
    protocol: TCP
    targetPort: 80
  - name: multitool
    port: 8080
    protocol: TCP
    targetPort: 8080
```

```bash
$ kubectl get svc/task1-svc 
NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
task1-svc   ClusterIP   10.152.183.25   <none>        80/TCP,8080/TCP   40s
```

5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multitool
  labels:
    app: multitool
spec:
  containers:
  - name: multitool
    image: wbitt/network-multitool:alpine-extra
```

```bash
$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
task1-65958d99b4-2szhd   2/2     Running   0          5m27s
task1-65958d99b4-4ftfr   2/2     Running   0          5m27s
multitool                1/1     Running   0          6s
```

```bash
$ kubectl get svc/task1-svc 
NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
task1-svc   ClusterIP   10.152.183.25   <none>        80/TCP,8080/TCP   7m12s
```
```bash
$ kubectl exec multitool -- curl 10.152.183.25:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0  1678k      0 --:--:-- --:--:-- --:--:--  597k
$ kubectl exec multitool -- curl 10.152.183.25:8080
WBITT Network MultiTool (with NGINX) - task1-65958d99b4-2szhd - 10.1.116.135 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   115  100   115    0     0   326k      0 --:--:-- --:--:-- --:--:--  112k
```

#### Ответ:
<details> <summary> Манифест:</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task1
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool:alpine-extra
        env:
        - name: HTTP_PORT
          value: "8080"
        ports:
        - containerPort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: task1-svc
spec:
  selector:
    app: nginx
  ports:
  - name: nginx
    port: 80
    protocol: TCP
    targetPort: 80
  - name: multitool
    port: 8080
    protocol: TCP
    targetPort: 8080
```

</details>

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task2
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      initContainers:
      - name: init-nginx
        image: busybox:1.28
        command: ['sh', '-c', "until nslookup nginx-service.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for nginx-service; sleep 2; done"]
```

2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.

```bash
$ kubectl get pods
NAME                     READY   STATUS     RESTARTS   AGE
task2-7c945d5655-pr45d   0/1     Init:0/1   0          12s
```

3. Создать и запустить Service. Убедиться, что Init запустился.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: task2-svc
spec:
  selector:
    app: nginx
  ports:
  - name: nginx
    port: 80
    protocol: TCP
    targetPort: 80
```

4. Продемонстрировать состояние пода до и после запуска сервиса.

```bash
$ kubectl get pods
NAME                    READY   STATUS     RESTARTS   AGE
task2-d44fd4c88-nxbnj   0/1     Init:0/1   0          2s
$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
task2-d44fd4c88-nxbnj   1/1     Running   0          7s
```

#### Ответ:
<details> <summary> Манифест:</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task2
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      initContainers:
      - name: init-nginx
        image: busybox:1.28
        command: ['sh', '-c', "until nslookup task2-svc.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for nginx service; sleep 2; done"]

---
apiVersion: v1
kind: Service
metadata:
  name: task2-svc
spec:
  selector:
    app: nginx
  ports:
  - name: nginx
    port: 80
    protocol: TCP
    targetPort: 80
```

</details>


------

### Правила приема работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md.

------
