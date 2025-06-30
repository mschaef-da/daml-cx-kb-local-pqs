#!/usr/bin/env bash
# Copyright 2025 Digital Asset (Switzerland) GmbH and/or its affiliates
# SPDX-License-Identifier: BSD0

set -eou pipefail

source "$(dirname "$0")/libcli.source"

psql postgres < scripts/init-pqs-db.sql

# Ensure that there's a party on ledger for the wildcard subscription to pick up.
./run allocate-party alice

java -jar target/scribe.jar pipeline ledger postgres-document --config scribe.conf
