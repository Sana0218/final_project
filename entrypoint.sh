#!/bin/bash
set -e

# server.pidが残っている場合に削除
rm -f /app/tmp/pids/server.pid

# Docker デプロイでは build 中に DB へ届かないため、起動時に migrate する
if [ "${RAILS_ENV}" = "production" ]; then
  bundle exec rails db:migrate
fi

exec "$@"
