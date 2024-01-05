#!/bin/false

# This file will be sourced in init.sh

function preflight_main() {
    preflight_do_something
}

function preflight_do_something() {
    printf "Empty preflight.sh...\n"
}

preflight_main "$@"