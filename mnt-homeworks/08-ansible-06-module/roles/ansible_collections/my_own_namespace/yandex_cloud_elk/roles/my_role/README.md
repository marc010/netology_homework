My_role
=========

This role creates a file and put a content into it.

Role Variables
--------------

| Name    | Required | Description                     | 
|---------|----------|---------------------------------|
| path    | True     | it is the path to a future file |
| content | False    | it is content to a future file  | 


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: my_role }

License
-------

MIT

Author Information
------------------

Ilya T.
