#!/usr/bin/env python3

import socket
import time
import json
import yaml

server_names = {"drive.google.com": "", "mail.google.com": "", "google.com": ""}

def create_json(service):
    with open("json.json", "w") as js_file:
        js_file.write(json.dumps(service, indent=2))

def create_yaml(service):
    with open("yaml.yaml", "w") as yaml_file:
        # yaml_file.write(yaml.safe_dump(service, indent=2))
        for dns, ip in service.items():
            yaml.safe_dump([{dns: ip}], yaml_file, indent=2)

# Первоначальное заполнение
for dns in server_names.keys():
    try:
        ip = socket.gethostbyname(dns)
        server_names[dns] = ip
    except socket.gaierror:
        print(f"[!] Error Name or service not known: {dns}")
        server_names[dns] = "0.0.0.0"
create_json(server_names)
create_yaml(server_names)

while True:
    for dns in server_names.keys():
        try:
            ip = socket.gethostbyname(dns)
            if server_names[dns] == ip:
                print(dns, '-', ip)
            else:
                print(f"[ERROR] {dns} IP mismatch: {server_names[dns]} {ip}")
                print(dns, '-', ip)
                server_names[dns] = ip
        except socket.gaierror:
            print(f"[!] Error Name or service not known: {dns}")
            server_names[dns] = "0.0.0.0"
    print("__________________________________________")
    create_json(server_names)
    create_yaml(server_names)
    time.sleep(2)
