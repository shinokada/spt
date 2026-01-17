#!/usr/bin/env bash
# shellcheck shell=bash

first() {
    # $1 can be /,:,=, etc
    item=$2
    echo "${item%"$1"*}"
}

second() {
    item=$2
    echo "${item##*"$1"}"
}
