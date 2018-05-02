#!/bin/bash

# This is a wrapper for the Auth0 NodeJS `wt-cli` tool
# Note that we use this because there aren't any supported API wrappers for Python as this time,
# and we're not sure how stable the API is for us to write our own wrapper.

# This script requires `wt-cli` for NodeJS to be installed:
# npm i wt-cli

# This also requires `wt-cli` to be setup:
## For new webtask users:
# wt profile init
# <follow instructions>
## For Auth0 webtask users with an existing environment:
# wt profile init
#  Profile:     default
#  URL:         https://webtask-dev.mozilla.auth0.com
#  Container:   auth-dev
#  Version:     v1

## Usage!
function usage() {
    echo "$0 [OPTIONS] <webtask_filename>"
    exit 127
}

## Argument parser
function parse_args() {
    local OPTIONS LONGOPTIONS PARSED
    OPTIONS=dp:
    LONGOPTIONS=debug,profile:
    PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")

    if [[ $? -ne 0 ]]; then
        usage
    fi

    eval set -- "$PARSED"

    # Defaults
    profile="default"
    debug=0

    # Parser assignment
    while true; do
        case "$1" in
            -d|--debug)
                debug=1
                shift
                ;;
            -p|--profile)
                profile="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Arguments parsing error"
                exit 127
                ;;
        esac
    done

    if [[ $# -ne 1 ]]; then
        usage
    else
        filename=$1
    fi
}

## Checks if utilities are present
function programs_check() {
    local p
    p="jq wt"

    for i in $p; do
        which wt > /dev/null || {
            echo "Please install wt-cli"
            exit 127
        }
    done
}

## Fatal echo
function fatal() {
    echo "FATAL: $*"
    exit 127
}

## Echo debug msgs
function debug() {
    [[ $debug -eq 0 ]] && return
    echo "DEBUG: $*"
}

## Returns JSON data as key=value
function json_to_bash_name() {
    cat $1 | jq -r '.name' || {
        fatal "failed to get json name"
    }
}

function json_to_bash_meta() {
    cat $1 | jq -r '.meta | to_entries[] |  "\(.key)=\(.value)"' || {
        fatal "failed to get json meta"
    }
}

## List all remote webtasks
function webtask_list_remote() {
    alias wt="wt -p $profile"
    debug "Listing remote webtasks"
    wt ls -o json | jq -r '.[]|.name'
}

## Program start
function main() {
    local name meta args exists
    alias wt="wt -p $profile"
    debug "utilizing webtask profile $profile"

    name=$(json_to_bash_name "$filename.json")
    meta=$(json_to_bash_meta "$filename.json")
    args=""
    for m in $meta; do
        args="--meta $m $args"
    done

    exists=0
    wt inspect $name > /dev/null && {
        exists=1
    }
    if [[ $exists -eq 1 ]]; then
        debug "Updating webtask $name ($filename)"
        wt update $name $filename || {
            fatal "Could not update webtask $name ($filename)"
        }
    else
        debug "Creating webtask $name ($filename)"
        wt create --name $name $args $filename || {
            fatal "Could not create webtask $name ($filename)"
        }
    fi
}

parse_args $*
programs_check
main
