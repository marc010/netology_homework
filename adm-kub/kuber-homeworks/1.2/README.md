# Домашнее задание к занятию «Базовые объекты K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Pod с приложением и подключиться к нему со своего локального компьютера. 

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. Описание [Pod](https://kubernetes.io/docs/concepts/workloads/pods/) и примеры манифестов.
2. Описание [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

------

### Задание 1. Создать Pod с именем hello-world

1. Создать [манифест](data/one_pod.yaml) (yaml-конфигурацию) Pod.
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.

[Манифест:](data/one_pod.yaml)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
    - name: hello-world
      image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
```

3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

```bash
$ kubectl port-forward hello-world 8080:8080 --address='0.0.0.0'
Forwarding from 0.0.0.0:8080 -> 8080
Handling connection for 8080
```

```bash
$ curl 192.168.56.11:8080


Hostname: hello-world

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://192.168.56.11:8080/

Request Headers:
	accept=*/*  
	host=192.168.56.11:8080  
	user-agent=curl/7.81.0  

Request Body:
	-no body in request-
```

------

### Задание 2. Создать Service и подключить его к Pod

1. Создать Pod с именем netology-web.
2. Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Создать Service с именем netology-svc и подключить к netology-web.
4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере).


[Манифест:](data/service.yaml)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: netology-web
  labels:
    app: netology-web
spec:
  containers:
    - name: netology-web
      image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2

---
apiVersion: v1
kind: Service
metadata:
  name: netology-svc
spec:
  selector:
    app: netology-web
  ports:
    - name: http
      port: 8080
      protocol: TCP
      targetPort: 8080
    - name: https
      port: 8443
      protocol: TCP
      targetPort: 8443 
```

```bash
$ kubectl port-forward services/netology-svc 8080:8080 8443:8443 --address='0.0.0.0'
```

```bash
$ curl 192.168.56.11:8080


Hostname: netology-web

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://192.168.56.11:8080/

Request Headers:
	accept=*/*  
	host=192.168.56.11:8080  
	user-agent=curl/7.81.0  

Request Body:
	-no body in request-
```

```bash
$ curl --insecure https://192.168.56.11:8443


Hostname: netology-web

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=2
	request_scheme=https
	request_uri=https://192.168.56.11:8443/

Request Headers:
	accept=*/*  
	host=192.168.56.11:8443  
	user-agent=curl/7.81.0  

Request Body:
```



------

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода команд `kubectl get pods`, а также скриншот результата подключения.
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md.
