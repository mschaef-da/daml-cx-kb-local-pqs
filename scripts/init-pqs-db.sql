-- Copyright 2025 Digital Asset (Switzerland) GmbH and/or its affiliates
-- SPDX-License-Identifier: BSD0

SELECT 'CREATE ROLE pqs WITH LOGIN'
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'pqs')\gexec

SELECT 'CREATE DATABASE pqs WITH OWNER pqs'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'pqs')\gexec
