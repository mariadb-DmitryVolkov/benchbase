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
        required=False,
    )

    parser.add_argument(
        "-tb",
        "--terminals_chbenchmark",
        action="store",
        dest="terminals",
        help="terminals to update",
        required=False,
    )

    parser.add_argument(
        "-tt",
        "--terminals_tpcc",
        action="store",
        dest="terminals",
        help="terminals to update",
        required=False,
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
    randomseed = args.randomseed

    with open(xml_config_file_name) as xml:
        data = xmltodict.parse(xml.read())

    if args.terminals is not None:
        data["parameters"]["terminals"] = args.terminals

    if args.terminals_chbenchmark is not None:
        data["parameters"]["terminals_chbenchmark"] = args.terminals_chbenchmark
        # 'rate': [{'@bench': 'chbenchmark', '#text': 'unlimited'}, {'@bench': 'tpcc', '#text': 'unlimited'}]
        rate = "unlimited" if args.terminals_chbenchmark > 0 else "disabled"
        data["parameters"]["works"]["work"]["rate"] = [
            {"@bench": "chbenchmark", "#text": rate}
        ]

    if args.terminals_tpcc is not None:
        data["parameters"]["terminals_tpcc"] = args.terminals_tpcc
        rate = "unlimited" if args.terminals_tpcc > 0 else "disabled"
        data["parameters"]["works"]["work"]["rate"].append(
            {"@bench": "tpcc", "#text": rate}
        )

    data["parameters"]["randomSeed"] = randomseed

    with open(xml_config_file_name, "w") as result_file:
        result_file.write(xmltodict.unparse(data, pretty=True))


if __name__ == "__main__":
    main()
