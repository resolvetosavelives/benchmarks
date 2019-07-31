#!/bin/bash

set -euxo

rm -f /src/tmp/pids/server.pid

exec "$@"
