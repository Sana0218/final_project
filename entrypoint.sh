#!/bin/bash
set -e

# server.pidが残っている場合に削除
rm -f /app/tmp/pids/server.pid

exec "$@"