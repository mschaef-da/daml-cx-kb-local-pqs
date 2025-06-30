#!/usr/bin/env bash
# Copyright 2025 Digital Asset (Switzerland) GmbH and/or its affiliates
# SPDX-License-Identifier: BSD0

set -euo pipefail

source "$(dirname "$0")/libcli.source"

dar_opts=""

for dar_file in "$@"
do
    _info "Loading Dar file: ${dar_file}"

    if [ ! -f ${dar_file} ]; then
        _error "DAR file ${dar_file} not found."
    fi

    dar_opts="${dar_opts} --dar ${dar_file}"
done

mkdir -pv log

daml sandbox --debug ${dar_opts} 
