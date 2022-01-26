#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

bin/rails db:migrate 2>/dev/null || bin/rails db:create db:setup

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"