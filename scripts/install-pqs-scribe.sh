#!/usr/bin/env bash
# Copyright 2025 Digital Asset (Switzerland) GmbH and/or its affiliates
# SPDX-License-Identifier: BSD0


set -eou pipefail

source "$(dirname "$0")/libcli.source"

versions_yaml="$1"
output="$2"
if [ -z "$versions_yaml" ] || [ -z "$output" ]; then
    _error "Usage - $0 <path to versions yaml> <download output path>"
fi

function yaml_value() {
  local path=$1
  yq -re "$path" "$versions_yaml" 2>/dev/null
}

if ! url=$(yaml_value '.["scribe-url"]'); then
  _error "Cannot read Daml Scribe URL from $versions_yaml"
fi

_info "== Downloading Scribe
from: $url
to: $output"

curl --fail -u "$ARTIFACTORY_READONLY_USER:$ARTIFACTORY_READONLY_PASSWORD" -L "$url" -o "${output}"

_info "== Downloaded scribe."
