#!/bin/sh

# This script runs inside the container to perform a PostgreSQL database dump.
# It directly uses environment variables for authentication and configuration.
PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -U "$POSTGRES_USER" -F c -d "$POSTGRES_DB" -f /tmp/dumps/dump.sql
