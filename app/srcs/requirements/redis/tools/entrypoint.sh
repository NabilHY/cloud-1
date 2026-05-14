#!/bin/sh

redis-cli -v

echo "Starting Redis..."

exec "$@"