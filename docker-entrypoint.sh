#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f tmp/pids/server.pid

(echo "Migrating Database..." && bin/rails db:migrate 2>/dev/null) || (echo "Creating database..." && bin/rails db:create db:setup)

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
