#!/usr/bin/env bash

set -e

printf "[all]\n"

printf "master1   ansible_host="
terraform output -json k8s_master1_public_ip | jq -j "."
printf "   ip="
terraform output -json k8s_master1_private_ip | jq -j "."
printf "   etcd_member_name=etcd1\n"


for num in 1 2 3
do
printf "worker$num   ansible_host="
terraform output -json k8s_workers_public_ips | jq -j ".[$num-1]"
printf "   ip="
terraform output -json k8s_workers_private_ips | jq -j ".[$num-1]"
printf "\n"
done

printf "\n[all:vars]\n"
printf "ansible_user=user-yc\n"
printf "supplementary_addresses_in_ssl_keys=['"
terraform output -json k8s_master1_public_ip | jq -j "."
printf "']"
# printf "ansible_ssh_private_key_file=~/.ssh/id_rsa_yc"
printf "\n\n"

#printf "\n[bastion]\n"
#printf "bastion ansible_host="
#terraform output -json k8s_master1_public_ip | jq -j "."
#printf " ansible_user=user-yc"
#
#printf "\n\n"

cat << EOF
[kube_control_plane]
master1

[etcd]
master1

[kube_node]
worker1
worker2
worker3

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr

EOF