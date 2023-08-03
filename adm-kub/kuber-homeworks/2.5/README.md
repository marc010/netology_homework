# Домашнее задание к занятию «Helm»

### Цель задания

В тестовой среде Kubernetes необходимо установить и обновить приложения с помощью Helm.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение, например, MicroK8S.
2. Установленный локальный kubectl.
3. Установленный локальный Helm.
4. Редактор YAML-файлов с подключенным репозиторием GitHub.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://helm.sh/docs/intro/install/) по установке Helm. [Helm completion](https://helm.sh/docs/helm/helm_completion/).

------

### Задание 1. Подготовить Helm-чарт для приложения

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 

Создадим шаблон при помощи команды `helm create <chart name>`. Helm создаст каталог с именем чарта.
Для выполнения дз оставим файлы `Chart.yaml` и `values.yaml`, а также файлы `deployment.yaml`, `service.yaml` и 
`ingress.yaml` в каталоге `templetes`. Со следующим содержимым:

deployment.yaml:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  {{- $release := .Release.Name }}
  name: {{ .Values.deployment.name }}{{ $release }}
  namespace: {{ .Values.namespace }}
  labels:
    {{ .Values.deployment.labels.key }}: {{ .Values.deployment.labels.value }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{ .Values.deployment.labels.key }}: {{ .Values.deployment.labels.value }}
  template:
    metadata:
      labels:
        {{ .Values.deployment.labels.key }}: {{ .Values.deployment.labels.value }}
    spec:
      containers:
      - name: {{ .Values.deployment.name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        ports:
        - name: {{ .Values.deployment.portName }}         
          containerPort: {{ .Values.deployment.appPort }}
```

service.yaml:

```yaml
apiVersion: v1
kind: Service
metadata:
  {{- $release := .Release.Name }}
  name: {{ .Values.service.name }}{{ $release }}
  namespace: {{ .Values.namespace }}
spec:
  selector:
    {{ .Values.deployment.labels.key }}: {{ .Values.deployment.labels.value }}
  ports:
  - name: {{ .Values.deployment.portName }}
    port: {{ .Values.service.port }}
    protocol: TCP
    targetPort: {{ .Values.service.port }}
  type: {{ .Values.service.type }}
```

ingress.yaml:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  {{- $release := .Release.Name }}
  name: ingress{{ $release }}
  namespace: {{ .Values.namespace }}
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: {{ .Values.ingress.className }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            {{- end }}
    {{- end }}
            backend:
              service:
                name: {{ .Values.service.name }}
                port:
                  name: {{ .Values.deployment.portName }}
```

Chart.yaml:

```yaml
apiVersion: v2
name: netology
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.16.0"
```

values.yaml:

```yaml
replicaCount: 1
namespace: ns1

deployment:
  name: nginx-netology
  appPort: 80
  portName: nginx-web
  labels:
    key: app
    value: netology-demo
    
image:
  repository: nginx
  tag: ""

service:
  name: netology-svc
  type: ClusterIP
  port: 80

ingress:
  className: ""
  hosts:
    - host: netology.local
      paths:
        - path: /
          pathType: Prefix
```

2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.
3. В переменных чарта измените образ приложения для изменения версии.

------
### Задание 2. Запустить две версии в разных неймспейсах

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.

```bash
$ helm template netology
---
# Source: netology/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: netology-svcrelease-name
  namespace: ns1
spec:
  selector:
    app: netology-demo
  ports:
  - name: nginx-web
    port: 80
    protocol: TCP
    targetPort: 80
  type: ClusterIP
---
# Source: netology/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-netologyrelease-name
  namespace: ns1
  labels:
    app: netology-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: netology-demo
  template:
    metadata:
      labels:
        app: netology-demo
    spec:
      containers:
      - name: nginx-netology
        image: "nginx:1.16.0"
        ports:
        - name: nginx-web         
          containerPort: 80
---
# Source: netology/templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingressrelease-name
  namespace: ns1
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: 
  rules:
    - host: "netology.local"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: netology-svc
                port:
                  name: nginx-web
```

2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.

```bash
$ helm install ns1-1-16-0 netology 
NAME: ns1-1-16-0
LAST DEPLOYED: Thu Aug  3 22:00:58 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
$ helm install ns1-1-19-1 netology --set image.tag=1.19.1
NAME: ns1-1-19-1
LAST DEPLOYED: Thu Aug  3 22:01:27 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
$ helm install ns1-1-21-1 netology --set image.tag=1.21.1,namespace=ns2
NAME: ns1-1-21-1
LAST DEPLOYED: Thu Aug  3 22:01:50 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

3. Продемонстрируйте результат.

```bash
$ kubectl get all -n ns1
NAME                                            READY   STATUS    RESTARTS   AGE
pod/nginx-netologyns1-1-16-0-5566b87cd4-6pgvf   1/1     Running   0          73s
pod/nginx-netologyns1-1-19-1-869d76d76b-8mf8m   1/1     Running   0          46s

NAME                             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/netology-svcns1-1-16-0   ClusterIP   10.152.183.52   <none>        80/TCP    76s
service/netology-svcns1-1-19-1   ClusterIP   10.152.183.26   <none>        80/TCP    46s

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-netologyns1-1-16-0   1/1     1            1           75s
deployment.apps/nginx-netologyns1-1-19-1   1/1     1            1           46s

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-netologyns1-1-16-0-5566b87cd4   1         1         1       75s
replicaset.apps/nginx-netologyns1-1-19-1-869d76d76b   1         1         1       46s
$ kubectl get all -n ns2
NAME                                            READY   STATUS    RESTARTS   AGE
pod/nginx-netologyns1-1-21-1-66b7bd447c-r7h2h   1/1     Running   0          26s

NAME                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/netology-svcns1-1-21-1   ClusterIP   10.152.183.221   <none>        80/TCP    28s

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-netologyns1-1-21-1   1/1     1            1           29s

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-netologyns1-1-21-1-66b7bd447c   1         1         1       28s
```

[Helm chart](./data/netology/)

### Правила приёма работы

1. Домашняя работа оформляется в своём Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, `helm`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

