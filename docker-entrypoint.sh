#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

Xvfb :99 -screen 0 1280x1024x24 &
export DISPLAY=:99

if [ "$1" = 'rails' ]; then
  exec bundle exec "$@"
elif [ "$1" = 'rspec' ]; then
  exec bundle exec "$@"
else
  exec "$@"
fi
