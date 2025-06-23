#!/bin/bash

# log function helps to print info messages
log() {
    echo "-- [ZK-CEREMONY:INFO] -- $1"
}
# error function helps to print error messages
error() {
    echo "-- [ZK-CEREMONY:ERROR] -- $1"
    exit 1
}

# include the environment variables
if [ ! -f "./ceremony.env" ]; then
    error "ceremony.env file not found"
else
    set -a
    source ./ceremony.env
    set +a
fi

HASH=b2sum
CIRCOM=circom

INPUT_PTAU_PATH="/circuits/powersOfTau28_hez_final_18.ptau"
CONTRIBUTIONS_PATH="${CONTRIBUTIONS_PATH:-"./contributions"}"
OUTPUT_PATH="${OUTPUT_PATH:-"./results"}"

get_file_hash() {
    # get the hash of the file and return the first part, the second part is
    # the file name
    echo "$($HASH "$1" | cut -d ' ' -f 1)"
}

get_last_contribution_file_path() {
    circuit_name=$1
    contribution_path=$2
    contribution_file=$contribution_path/CONTRIBUTIONS.md
    local last_contribution=$(tail -n 2 $contribution_file | head -n 1)
    local last_contribution_filepath=$contribution_path/${circuit_name}_initial_contribution.zkey
    if [ "$last_contribution" != "" ]; then
        IFS=":"
        read -ra parts <<<"$last_contribution"
        last_contribution_filepath=$contribution_path/${parts[0]}
    fi
    echo "$last_contribution_filepath"
}

get_last_contribution_hash() {
    local last_contribution=$(tail -n 2 $1 | head -n 1)
    local last_contribution_hash="<check CONTRIBUTIONS.md file>"
    if [ "$last_contribution" != "" ]; then
        IFS=":"
        read -ra parts <<<"$last_contribution"
        last_contribution_hash=${parts[1]}
    fi
    echo "$last_contribution_hash"
}

ask_to_user() {
    local asnwer=""
    while true; do
        read -p "$1 " answer
        # Check if the alias is not empty
        if [ -n "$answer" ]; then
            break
        fi
    done
    echo "$answer"
}
