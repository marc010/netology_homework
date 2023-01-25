#!/usr/bin/env bash


docker run -d -it --rm --name fedora pycontribs/fedora
docker run -d -it --rm --name ubuntu python
docker run -d -it --rm --name centos7 centos:7

ansible-playbook -i inventory/prod.yml site.yml

docker stop $(docker ps -a -q)
