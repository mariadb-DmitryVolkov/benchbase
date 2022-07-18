#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (C) 2022 dvolkov
# Update config for benchbase for the next run

import argparse

import xmltodict


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-c",
        "--config",
        action="store",
        dest="config",
        help="config file to update",
        required=True,
    )

    parser.add_argument(
        "-t",
        "--terminals",
        action="store",
        dest="terminals",
        help="terminals to update",
        required=True,
    )
    parser.add_argument(
        "-r",
        "--randomseed",
        action="store",
        dest="randomseed",
        help="random seed to update",
        required=True,
    )

    args = parser.parse_args()
    xml_config_file_name = args.config
    terminals = args.terminals
    randomseed = args.randomseed

    with open(xml_config_file_name) as xml:
        data = xmltodict.parse(xml.read())

    data["parameters"]["terminals"] = terminals
    data["parameters"]["randomSeed"] = randomseed

    with open(xml_config_file_name, "w") as result_file:
        result_file.write(xmltodict.unparse(data, pretty=True))


if __name__ == "__main__":
    main()
