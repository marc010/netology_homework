#!/usr/bin/python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_own_module

short_description: This is my test module

version_added: "1.0.0"

description: This is my test module. It can create file and put some content there.

options:
    path:
        description: This is the path to a new file.
        required: true
        type: str
    content:
        description: This is some text which would be put in the file
        required: false
        type: str

extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Ilya T. (github.com/marc010)
'''

EXAMPLES = r'''
# Create defalt test file
- name: Create default test file
  my_namespace.my_collection.my_own_module:
    path: '/tmp/test.txt' 

# Create file with special content
- name: Create file with special content
  my_namespace.my_collection.my_own_module:
    path: '/tmp/test.txt'
    content: 'some other content'

'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'File created'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'File created'
'''

from ansible.module_utils.basic import AnsibleModule
from os import path

def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
            path=dict(type='str', required=True),
            content=dict(type='str', required=False, default='test')
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        if path.exists(module.params['path']):
            result['cahnged'] = True
        module.exit_json(**result)
    
    if not path.exists(module.params['path']):
        with open(module.params['path'], 'w' ) as file:
            file.write(module.params['content'])
        result['changed'] = True
        result['original_messege'] = 'File created'
        result['message'] = 'File created'
    else:
        with open(module.params['path'], 'r' ) as file:
            current_content = file.read()
        if current_content != module.params['content']:
            with open(module.params['path'], 'w' ) as file:
                file.write(module.params['content'])
            result['changed'] = True
            result['original_messege'] = 'File exists, but the content was updated'
            result['message'] = 'File exists, but the content was updated'
        else:
            result['original_messege'] = 'File alrady exists'
            result['message'] = 'File already exists'
        
    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
