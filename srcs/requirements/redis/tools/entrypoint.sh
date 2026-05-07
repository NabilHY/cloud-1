#!/bin/sh

redis-cli -v

echo "Starting Redis..."

redis-server --protected-mode no 