#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f tmp/pids/server.pid

# This command resets the db when migrations apply partially on a new database.
#DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bin/rails db:environment:set db:schema:load db:seed
(echo "Migrating Database..." && bin/rails db:migrate 2>/dev/null) || (echo "Creating database..." && bin/rails db:create db:environment:set db:schema:load db:seed)

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
