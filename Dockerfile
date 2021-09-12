# syntax=docker/dockerfile:1

#FROM whoihrbenchmarksregistry.azurecr.io/benchmarks_builder:latest AS Builder
# for working locally
FROM benchmarks_builder:latest AS Builder
#FROM whoihrbenchmarksregistry.azurecr.io/benchmarks_base:latest AS Base
# for working locally
FROM benchmarks_base:latest AS Base

# Workaround to trigger Builder's ONBUILDs to finish:
COPY --from=Builder /etc/alpine-release /tmp/dummy

WORKDIR $REPO_HOME
# set USER last cuz most other commanded needed to run as root, but we want to run server as non-root
#USER app:app
# NB: we are not using ENTRYPOINT because it does not pass Unix signals
CMD echo "WHOAMI: `whoami`" && \
    env | sort && \
    echo "output of gem env: " && \
    gem env && \
    echo "output of bundle config: " && \
    bundle config && \
    echo "output of bundle env: " && \
    bundle env && \
    echo "ls -la PWD (`pwd`): " && \
    ls -la && \
    RAILS_ENV=$RAILS_ENV DATABASE_URL=$DATABASE_URL RAILS_MASTER_KEY=$RAILS_MASTER_KEY NO_SSL=true WEBSITE_HOSTNAME=$WEBSITE_HOSTNAME bundle exec puma -p 80 -w 0 -t 0:5
