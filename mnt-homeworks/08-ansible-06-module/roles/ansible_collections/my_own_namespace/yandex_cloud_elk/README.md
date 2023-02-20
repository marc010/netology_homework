Ansible Collection - my_own_namespace.yandex_cloud_elk
---

This collection creates a file and put a content into it.

Ansible verion compatibility
---

Use this collection with Ansible Core 2.14 or greater.

Python version compatibility
---

This collection requires Python 3.6 or greater.

Using this collection
---

```ansible
---
- name: Test module
  hosts: localhost
  tasks:
    - name: Call my_own_module
      my_own_module:
        path: "/tmp/testfile.txt"
        content: "TEST from playbook"
```

Options
---

| Name    | Required | Description                     | 
|---------|----------|---------------------------------|
| path    | True     | it is the path to a future file |
| content | False    | it is content to a future file  | 

License
---

MIT
