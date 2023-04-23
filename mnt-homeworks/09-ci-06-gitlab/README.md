# Домашнее задание к занятию 12 «GitLab»

## Подготовка к выполнению

1. Подготовьте к работе GitLab [по инструкции](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/gitlab-containers).
2. Создайте свой новый проект.
3. Создайте новый репозиторий в GitLab, наполните его [файлами](./repository).
4. Проект должен быть публичным, остальные настройки по желанию.

## Основная часть

### DevOps

В репозитории содержится код проекта на Python. Проект — RESTful API сервис. Ваша задача — автоматизировать сборку образа с выполнением python-скрипта:

1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated).
2. Python версии не ниже 3.7.
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`.
4. Создана директория `/python_api`.
5. Скрипт из репозитория размещён в /python_api.
6. Точка вызова: запуск скрипта.
7. При комите в любую ветку должен собираться docker image с форматом имени hello:gitlab-$CI_COMMIT_SHORT_SHA . Образ должен быть выложен в Gitlab registry или yandex registry.   
8.* (задание необязательное к выполению) При комите в ветку master после сборки должен подняться pod в kubernetes. Примерный pipeline для push в kubernetes по [ссылке](https://github.com/awertoss/devops-netology/blob/main/09-ci-06-gitlab/gitlab-ci.yml).
Если вы еще не знакомы с k8s - автоматизируйте сборку и деплой приложения в docker на виртуальной машине.

![pipeline](./media/pipeline.png)

### Product Owner

Вашему проекту нужна бизнесовая доработка: нужно поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:

1. Какой метод необходимо исправить.
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`.
3. Issue поставить label: feature.

![issue](./media/issue.png)


### Developer

Пришёл новый Issue на доработку, вам нужно:

1. Создать отдельную ветку, связанную с этим Issue.
2. Внести изменения по тексту из задания.
3. Подготовить Merge Request, влить необходимые изменения в `master`, проверить, что сборка прошла успешно.

![dev1](./media/merge.png)
![dev](./media/developer.png)

### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:

1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность.

```bash
$ echo <oauth-токен> | docker login --username oauth --password-stdin cr.yandex
```
```bash
$ docker pull cr.yandex/crphnklrgefscfbi5ii3/hello:gitlab-55445b08
```
```bash
$ docker run -d --rm -p 5290:5290 cr.yandex/crphnklrgefscfbi5ii3/hello:gitlab-55445b08
```
```bash
$ curl localhost:5290/get_info
{"version": 3, "method": "GET", "message": "Running"}
```

2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый.

## Итог

В качестве ответа пришлите подробные скриншоты по каждому пункту задания:

- файл [gitlab-ci.yml](./repository/.gitlab-ci.yml);
- [Dockerfile](./repository/Dockerfile); 
- лог успешного выполнения пайплайна;

![log1](./media/log1.png)
```bash
Running with gitlab-runner 15.10.1 (dcfb4b66)
  on gitlab-runner-5d58bf765-hsbbm Su1uoBEj, system ID: r_On4IPZBaAKe2
Preparing the "kubernetes" executor 00:00
Using Kubernetes namespace: default
Using Kubernetes executor with image gcr.io/cloud-builders/kubectl:latest ...
Using attach strategy to execute scripts...
Preparing environment 00:11
Waiting for pod default/runner-su1uobej-project-3-concurrent-06n5hj to be running, status is Pending
Waiting for pod default/runner-su1uobej-project-3-concurrent-06n5hj to be running, status is Pending
	ContainersNotInitialized: "containers with incomplete status: [init-permissions]"
	ContainersNotReady: "containers with unready status: [build helper]"
	ContainersNotReady: "containers with unready status: [build helper]"
Waiting for pod default/runner-su1uobej-project-3-concurrent-06n5hj to be running, status is Pending
	ContainersNotReady: "containers with unready status: [build helper]"
	ContainersNotReady: "containers with unready status: [build helper]"
Running on runner-su1uobej-project-3-concurrent-06n5hj via gitlab-runner-5d58bf765-hsbbm...
Getting source from Git repository 00:03
Fetching changes with git depth set to 20...
Initialized empty Git repository in /builds/marc/netology/.git/
Created fresh repository.
Checking out 2f7ac313 as detached HEAD (ref is main)...
Skipping Git submodules setup
Executing "step_script" stage of the job script 00:10
$ kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
Cluster "k8s" set.
$ kubectl config set-credentials admin --token="$KUBE_TOKEN"
User "admin" set.
$ kubectl config set-context default --cluster=k8s --user=admin
Context "default" created.
$ kubectl config use-context default
Switched to context "default".
$ sed -i "s/__VERSION__/gitlab-$CI_COMMIT_SHORT_SHA/" k8s.yaml
$ kubectl apply -f k8s.yaml
namespace/hello-world unchanged
deployment.apps/hello-world-deployment configured
Cleaning up project directory and file based variables 00:01
Job succeeded
```
```bash
Running with gitlab-runner 15.10.1 (dcfb4b66)
  on gitlab-runner-5d58bf765-hsbbm Su1uoBEj, system ID: r_On4IPZBaAKe2
Preparing the "kubernetes" executor 00:01
Using Kubernetes namespace: default
Using Kubernetes executor with image cr.yandex/yc/metadata-token-docker-helper:0.2 ...
Using attach strategy to execute scripts...
Preparing environment 00:08
Waiting for pod default/runner-su1uobej-project-3-concurrent-046m9l to be running, status is Pending
Waiting for pod default/runner-su1uobej-project-3-concurrent-046m9l to be running, status is Pending
	ContainersNotInitialized: "containers with incomplete status: [init-permissions]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
	ContainersNotReady: "containers with unready status: [build helper svc-0]"
Running on runner-su1uobej-project-3-concurrent-046m9l via gitlab-runner-5d58bf765-hsbbm...
Getting source from Git repository 00:03
Fetching changes with git depth set to 20...
Initialized empty Git repository in /builds/marc/netology/.git/
Created fresh repository.
Checking out 2f7ac313 as detached HEAD (ref is main)...
Skipping Git submodules setup
Executing "step_script" stage of the job script 02:28
$ docker build . -t cr.yandex/crphnklrgefscfbi5ii3/hello:gitlab-$CI_COMMIT_SHORT_SHA
Step 1/7 : FROM centos:7
7: Pulling from library/centos
2d473b07cdd5: Pulling fs layer
2d473b07cdd5: Verifying Checksum
2d473b07cdd5: Download complete
2d473b07cdd5: Pull complete
Digest: sha256:be65f488b7764ad3638f236b7b515b3678369a5124c47b8d32916d6487418ea4
Status: Downloaded newer image for centos:7
 ---> eeb6ee3f44bd
Step 2/7 : WORKDIR /python_api
 ---> Running in 7c4ecaf923bc
Removing intermediate container 7c4ecaf923bc
 ---> ddc455dab192
Step 3/7 : RUN yum install python3 python3-pip -y
 ---> Running in 8e47bd236ad8
Loaded plugins: fastestmirror, ovl
Determining fastest mirrors
 * base: mirror.yandex.ru
 * extras: mirrors.datahouse.ru
 * updates: mirror.yandex.ru
Resolving Dependencies
--> Running transaction check
---> Package python3.x86_64 0:3.6.8-18.el7 will be installed
--> Processing Dependency: python3-libs(x86-64) = 3.6.8-18.el7 for package: python3-3.6.8-18.el7.x86_64
--> Processing Dependency: python3-setuptools for package: python3-3.6.8-18.el7.x86_64
--> Processing Dependency: libpython3.6m.so.1.0()(64bit) for package: python3-3.6.8-18.el7.x86_64
---> Package python3-pip.noarch 0:9.0.3-8.el7 will be installed
--> Running transaction check
---> Package python3-libs.x86_64 0:3.6.8-18.el7 will be installed
--> Processing Dependency: libtirpc.so.1()(64bit) for package: python3-libs-3.6.8-18.el7.x86_64
---> Package python3-setuptools.noarch 0:39.2.0-10.el7 will be installed
--> Running transaction check
---> Package libtirpc.x86_64 0:0.2.4-0.16.el7 will be installed
--> Finished Dependency Resolution
Dependencies Resolved
================================================================================
 Package                  Arch         Version              Repository     Size
================================================================================
Installing:
 python3                  x86_64       3.6.8-18.el7         updates        70 k
 python3-pip              noarch       9.0.3-8.el7          base          1.6 M
Installing for dependencies:
 libtirpc                 x86_64       0.2.4-0.16.el7       base           89 k
 python3-libs             x86_64       3.6.8-18.el7         updates       6.9 M
 python3-setuptools       noarch       39.2.0-10.el7        base          629 k
Transaction Summary
================================================================================
Install  2 Packages (+3 Dependent packages)
Total download size: 9.3 M
Installed size: 48 M
Downloading packages:
warning: /var/cache/yum/x86_64/7/updates/packages/python3-libs-3.6.8-18.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for python3-libs-3.6.8-18.el7.x86_64.rpm is not installed
Public key for libtirpc-0.2.4-0.16.el7.x86_64.rpm is not installed
--------------------------------------------------------------------------------
Total                                              5.3 MB/s | 9.3 MB  00:01     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-9.2009.0.el7.centos.x86_64 (@CentOS)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : libtirpc-0.2.4-0.16.el7.x86_64                               1/5
 
  Installing : python3-setuptools-39.2.0-10.el7.noarch                      2/5
 
  Installing : python3-pip-9.0.3-8.el7.noarch                               3/5 
  Installing : python3-3.6.8-18.el7.x86_64                                  4/5
 
  Installing : python3-libs-3.6.8-18.el7.x86_64                             5/5
 
  Verifying  : libtirpc-0.2.4-0.16.el7.x86_64                               1/5 
  Verifying  : python3-setuptools-39.2.0-10.el7.noarch                      2/5
 
  Verifying  : python3-libs-3.6.8-18.el7.x86_64                             3/5 
  Verifying  : python3-3.6.8-18.el7.x86_64                                  4/5 
  Verifying  : python3-pip-9.0.3-8.el7.noarch                               5/5
 
Installed:
  python3.x86_64 0:3.6.8-18.el7         python3-pip.noarch 0:9.0.3-8.el7        
Dependency Installed:
  libtirpc.x86_64 0:0.2.4-0.16.el7           python3-libs.x86_64 0:3.6.8-18.el7 
  python3-setuptools.noarch 0:39.2.0-10.el7 
Complete!
Removing intermediate container 8e47bd236ad8
 ---> 115345022760
Step 4/7 : COPY requirements.txt requirements.txt
 ---> 4638b8697d02
Step 5/7 : RUN pip3 install -r requirements.txt
 ---> Running in d5ac8e502cf3
WARNING: Running pip install with root privileges is generally not a good idea. Try `pip3 install --user` instead.
Collecting flask (from -r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/cd/77/59df23681f4fd19b7cbbb5e92484d46ad587554f5d490f33ef907e456132/Flask-2.0.3-py3-none-any.whl (95kB)
Collecting flask-jsonpify (from -r requirements.txt (line 2))
  Downloading https://files.pythonhosted.org/packages/60/0f/c389dea3988bffbe32c1a667989914b1cc0bce31b338c8da844d5e42b503/Flask-Jsonpify-1.5.0.tar.gz
Collecting flask-restful (from -r requirements.txt (line 3))
  Downloading https://files.pythonhosted.org/packages/a9/02/7e21a73564fe0d9d1a3a4ff478dfc407815c4e2fa4e5121bcfc646ba5d15/Flask_RESTful-0.3.9-py2.py3-none-any.whl
Collecting Werkzeug>=2.0 (from flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/f4/f3/22afbdb20cc4654b10c98043414a14057cd27fdba9d4ae61cea596000ba2/Werkzeug-2.0.3-py3-none-any.whl (289kB)
Collecting itsdangerous>=2.0 (from flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/9c/96/26f935afba9cd6140216da5add223a0c465b99d0f112b68a4ca426441019/itsdangerous-2.0.1-py3-none-any.whl
Collecting Jinja2>=3.0 (from flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/20/9a/e5d9ec41927401e41aea8af6d16e78b5e612bca4699d417f646a9610a076/Jinja2-3.0.3-py3-none-any.whl (133kB)
Collecting click>=7.1.2 (from flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/4a/a8/0b2ced25639fb20cc1c9784de90a8c25f9504a7f18cd8b5397bd61696d7d/click-8.0.4-py3-none-any.whl (97kB)
Collecting six>=1.3.0 (from flask-restful->-r requirements.txt (line 3))
  Downloading https://files.pythonhosted.org/packages/d9/5a/e7c31adbe875f2abbb91bd84cf2dc52d792b5a01506781dbcf25c91daf11/six-1.16.0-py2.py3-none-any.whl
Collecting pytz (from flask-restful->-r requirements.txt (line 3))
  Downloading https://files.pythonhosted.org/packages/7f/99/ad6bd37e748257dd70d6f85d916cafe79c0b0f5e2e95b11f7fbc82bf3110/pytz-2023.3-py2.py3-none-any.whl (502kB)
Collecting aniso8601>=0.82 (from flask-restful->-r requirements.txt (line 3))
  Downloading https://files.pythonhosted.org/packages/e3/04/e97c12dc034791d7b504860acfcdd2963fa21ae61eaca1c9d31245f812c3/aniso8601-9.0.1-py2.py3-none-any.whl (52kB)
Collecting dataclasses; python_version < "3.7" (from Werkzeug>=2.0->flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/fe/ca/75fac5856ab5cfa51bbbcefa250182e50441074fdc3f803f6e76451fab43/dataclasses-0.8-py3-none-any.whl
Collecting MarkupSafe>=2.0 (from Jinja2>=3.0->flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/fc/d6/57f9a97e56447a1e340f8574836d3b636e2c14de304943836bd645fa9c7e/MarkupSafe-2.0.1-cp36-cp36m-manylinux1_x86_64.whl
Collecting importlib-metadata; python_version < "3.8" (from click>=7.1.2->flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/a0/a1/b153a0a4caf7a7e3f15c2cd56c7702e2cf3d89b1b359d1f1c5e59d68f4ce/importlib_metadata-4.8.3-py3-none-any.whl
Collecting typing-extensions>=3.6.4; python_version < "3.8" (from importlib-metadata; python_version < "3.8"->click>=7.1.2->flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/45/6b/44f7f8f1e110027cf88956b59f2fad776cca7e1704396d043f89effd3a0e/typing_extensions-4.1.1-py3-none-any.whl
Collecting zipp>=0.5 (from importlib-metadata; python_version < "3.8"->click>=7.1.2->flask->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/bd/df/d4a4974a3e3957fd1c1fa3082366d7fff6e428ddb55f074bf64876f8e8ad/zipp-3.6.0-py3-none-any.whl
Installing collected packages: dataclasses, Werkzeug, itsdangerous, MarkupSafe, Jinja2, typing-extensions, zipp, importlib-metadata, click, flask, flask-jsonpify, six, pytz, aniso8601, flask-restful
  Running setup.py install for flask-jsonpify: started
    Running setup.py install for flask-jsonpify: finished with status 'done'
Successfully installed Jinja2-3.0.3 MarkupSafe-2.0.1 Werkzeug-2.0.3 aniso8601-9.0.1 click-8.0.4 dataclasses-0.8 flask-2.0.3 flask-jsonpify-1.5.0 flask-restful-0.3.9 importlib-metadata-4.8.3 itsdangerous-2.0.1 pytz-2023.3 six-1.16.0 typing-extensions-4.1.1 zipp-3.6.0
Removing intermediate container d5ac8e502cf3
 ---> 2e46908b2caa
Step 6/7 : COPY python-api.py python-api.py
 ---> dd847563082d
Step 7/7 : CMD ["python3", "python-api.py"]
 ---> Running in 213110c5e66a
Removing intermediate container 213110c5e66a
 ---> fc9e3c01018a
Successfully built fc9e3c01018a
Successfully tagged cr.yandex/crphnklrgefscfbi5ii3/hello:gitlab-2f7ac313
$ docker push cr.yandex/crphnklrgefscfbi5ii3/hello:gitlab-$CI_COMMIT_SHORT_SHA
The push refers to repository [cr.yandex/crphnklrgefscfbi5ii3/hello]
eb8f54cf173f: Preparing
e1eb1ee12b2b: Preparing
d73c4dfbb4e1: Preparing
b88d94e0cf1b: Preparing
4191ee61a3e8: Preparing
174f56854903: Preparing
174f56854903: Waiting
4191ee61a3e8: Pushed
eb8f54cf173f: Pushed
d73c4dfbb4e1: Pushed
174f56854903: Layer already exists
e1eb1ee12b2b: Pushed
b88d94e0cf1b: Pushed
gitlab-2f7ac313: digest: sha256:60939b52068c5d42c0cb97cce6c9a3ea6b530c3bfbb214d0c01cdf742b663e13 size: 1573
Cleaning up project directory and file based variables 00:03
Job succeeded
```

- решённый Issue.

![issue](./media/solved.png)