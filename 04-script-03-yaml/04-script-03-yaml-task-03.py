#!/usr/bin/env python3

import os
import argparse
import json
import yaml

parser = argparse.ArgumentParser(
    description="This program converts json to yaml and vice versa. A file is saved with the json or yaml extension. if the file with that name exists, the program will overwrite it.",
    usage="%(prog)s [options <args>]")
parser.add_argument('-f', "--file", help="add path to json or yaml file")
args = parser.parse_args()


def check_file_type(data):
    try:
        json_data = json.loads(data)
        from_dict_to_file(json_data, "json")

    except json.decoder.JSONDecodeError as json_er:
        if json_er.msg == "Expecting value" and json_er.lineno == 1 and json_er.colno == 1:  # maybe it's not a json file
            try:
                yaml_data = yaml.safe_load(data)
                if type(yaml_data) is dict:
                    from_dict_to_file(yaml_data, "yaml")  # add call function yaml to json
                else:
                    print("This is not a yaml or json file")

            except yaml.YAMLError as yaml_er:
                if yaml_er.args[1] is None:
                    print("This is not a yaml or json file")
                else:  # yaml with a mistake

                    print("--info--\nMaybe a yaml file with an error!")
                    print(f"Line: {yaml_er.context_mark.line + 1} Problem: {yaml_er.problem}")

        else:  # it is possible json with mistakes
            print("--info--\nMaybe a json file with an error!")
            print(f"Line: {json_er.lineno} Column: {json_er.colno}")


def from_dict_to_file(data, extension):
    file_name = args.file
    if extension == "yaml":
        if file_name.rfind(".yaml") != -1:
            file_name = file_name[:file_name.rfind(".yaml")] + ".json"
        else:
            file_name = file_name + ".json"
        with open(file_name, "w") as json_file:
            json_file.write(json.dumps(data, indent=2))
        print(f"Converted from yaml file '{args.file}' to json file '{file_name}'")
    elif extension == "json":
        if file_name.rfind(".json") != -1:
            file_name = file_name[:file_name.rfind(".json")] + ".yaml"
        else:
            file_name = file_name + ".yaml"
        with open(file_name, "w") as yaml_file:
            yaml_file.write(yaml.dump(data, indent=2))
        print(f"Converted from json file '{args.file}' to yaml file '{file_name}'")


if args.file is None:
    parser.print_help()
    exit()  # while there are no other options
else:
    if os.path.isfile(args.file):
        with open(args.file, "r") as file:
            data = file.read()
        check_file_type(data)
    else:
        print(f"File '{args.file}' doesn't exist!")
