#!/usr/bin/env bash
# Copyright 2025 Digital Asset (Switzerland) GmbH and/or its affiliates
# SPDX-License-Identifier: BSD0

set -eou pipefail

source "$(dirname "$0")/libcli.source"

psql postgres < scripts/drop-pqs-db.sql
