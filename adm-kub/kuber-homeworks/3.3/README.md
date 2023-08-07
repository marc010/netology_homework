# Домашнее задание к занятию «Как работает сеть в K8s»

### Цель задания

Настроить сетевую политику доступа к подам.

### Чеклист готовности к домашнему заданию

1. Кластер K8s с установленным сетевым плагином Calico.

```bash
$ kubectl get pods -n kube-system | grep calico
calico-node-mmswz                          1/1     Running   1 (2m2s ago)    3d23h
calico-kube-controllers-555886c9b9-t8dpv   1/1     Running   1 (2m2s ago)    3d23h
```

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Calico](https://www.tigera.io/project-calico/).
2. [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
3. [About Network Policy](https://docs.projectcalico.org/about/about-network-policy).

-----

### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа

1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.

Deployment example:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-frontend
  labels:
    app: multitool
  namespace: app
spec:
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: wbitt/network-multitool:alpine-extra
          ports:
          - name: frontend          
            containerPort: 80
```

Service example:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: app
spec:
  selector:
    app: frontend
  ports:
  - name: multitool-frontend
    port: 80
    protocol: TCP
    targetPort: 80
  type: ClusterIP
```


2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace App.

```bash
$ kubectl create namespace app
namespace/app created
```

```bash
$ kubectl apply -f dep_backend.yaml -f dep_frontend.yaml -f dep_cache.yaml -f svc_backend.yaml -f svc_frontend.yaml -f svc_cache.yaml 
deployment.apps/deployment-backend created
deployment.apps/deployment-frontend created
deployment.apps/deployment-cache created
service/backend-svc created
service/frontend-svc created
service/cache-svc created
```

4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.

Связность до настройки политик:
```bash
$ kubectl -n app exec deployment-backend-75d97bddf9-sjwnm -- curl frontend-svc.app.svc.cluster.local
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   129  100   129    0     0    439      0 --:--:-- --:--:-- --:--:--   440
WBITT Network MultiTool (with NGINX) - deployment-frontend-79c5985df7-l9g47 - 10.1.116.189 . (Formerly praqma/network-multitool)
```

Default network policy запрещающая передачу трафика по умолчанию:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: app
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

Связность после применения запрещающей политики по умолчанию:

```bash
$ kubectl -n app exec deployment-backend-75d97bddf9-sjwnm -- curl frontend-svc.app.svc.cluster.local
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:15 --:--:--     0^C
```

Network policy для backend. Разрешает прохождение трафика от frontend до backend по протоколу TCP на порт 80:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: frontend
      ports:
        - protocol: TCP
          port: 80
```

```bash
$ kubectl -n app exec deployment-frontend-79c5985df7-l9g47 -- curl backend-svc.app.svc.cluster.local
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   128  100   128    0     0    757      0 --:--:-- --:--:-- --:--:--   761
WBITT Network MultiTool (with NGINX) - deployment-backend-75d97bddf9-sjwnm - 10.1.116.190 . (Formerly praqma/network-multitool)
```

Network policy для cache. Разрешает прохождение трафика от backend до cache по протоколу TCP на порт 80:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: cache
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: cache
  policyTypes:
    - Ingress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: backend
      ports:
        - protocol: TCP
          port: 80
```

```bash
$ kubectl -n app exec deployment-backend-75d97bddf9-sjwnm -- curl cache-svc.app.svc.cluster.local
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   125  100   125    0     0   2882      0 --:--:-- --:--:-- --:--:--  2906
WBITT Network MultiTool (with NGINX) - deployment-cache-bb5ffb569-rrqtn - 10.1.116.188 . (Formerly praqma/network-multitool)
```

5. Продемонстрировать, что трафик разрешён и запрещён.

Трафик от frontend до backend:

```bash
$ kubectl -n app exec deployment-frontend-79c5985df7-l9g47 -- curl backend-svc.app.svc.cluster.local
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0WBITT Network MultiTool (with NGINX) - deployment-backend-75d97bddf9-sjwnm - 10.1.116.190 . (Formerly praqma/network-multitool)
100   128  100   128    0     0   3095      0 --:--:-- --:--:-- --:--:--  3121
```

В обратную сторону:

```bash
$ kubectl -n app exec deployment-backend-75d97bddf9-sjwnm -- curl frontend-svc.app.svc.cluster.local
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:11 --:--:--     0^C
```

Трафик от backend до cache:

```bash
$ kubectl -n app exec deployment-backend-75d97bddf9-sjwnm -- curl cache-svc.app.svc.cluster.local
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   125  100   125    0     0   WBITT Network MultiTool (with NGINX) - deployment-cache-bb5ffb569-rrqtn - 10.1.116.188 . (Formerly praqma/network-multitool)
2083      0 --:--:-- --:--:-- --:--:--  2118
```

В обратную сторону:

```bash
$ kubectl -n app exec deployment-cache-bb5ffb569-rrqtn -- curl backend-svc.app.svc.cluster.local
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:06 --:--:--     0^C
```

Трафик от frontend до cache:

```bash
$ kubectl -n app exec deployment-frontend-79c5985df7-l9g47 -- curl cache-svc.app.svc.cluster.local
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:06 --:--:--     0^C
```

[Манифесты](./data/)

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
