-- Copyright 2025 Digital Asset (Switzerland) GmbH and/or its affiliates
-- SPDX-License-Identifier: BSD0

SELECT 'DROP DATABASE pqs'
WHERE EXISTS (SELECT FROM pg_database WHERE datname = 'pqs')\gexec

SELECT 'DROP ROLE pqs'
WHERE EXISTS (SELECT FROM pg_roles WHERE rolname = 'pqs')\gexec

