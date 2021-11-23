# syntax=docker/dockerfile:1

FROM whoihrbenchmarksregistry.azurecr.io/benchmarks_builder:latest AS Builder
# for working locally, use this FROM line instead of the one above:
#FROM benchmarks_builder:latest AS Builder
FROM whoihrbenchmarksregistry.azurecr.io/benchmarks_base:latest AS Base
# for working locally, use this FROM line instead of the one above:
#FROM benchmarks_base:latest AS Base

# Workaround to trigger Builder's ONBUILDs to finish:
COPY --from=Builder /etc/alpine-release /tmp/dummy

WORKDIR $REPO_HOME
RUN rm /root/benchmarks/public/packs/css/*.gz
RUN rm /root/benchmarks/public/packs/css/*.br
# set USER last cuz most other commanded needed to run as root, but we want to run server as non-root
#USER app:app
# NB: we are not using ENTRYPOINT because it does not pass Unix signals
CMD echo "WHOAMI: `whoami`" && \
    env | sort && \
    echo "output of gem env: " && \
    bin/bundle exec /usr/local/bin/gem env && \
    echo "output of bundle config: " && \
    bin/bundle config && \
    echo "output of bundle env: " && \
    bin/bundle env && \
    echo "ls -la PWD (`pwd`): " && \
    ls -la && \
    echo "ls -la /root/benchmarks/vendor/bundle/ruby/3.0.0/bin: " && \
    ls -la /root/benchmarks/vendor/bundle/ruby/3.0.0/bin && \
    RAILS_ENV=$RAILS_ENV DATABASE_URL=$DATABASE_URL RAILS_MASTER_KEY=$RAILS_MASTER_KEY WEBSITE_HOSTNAME=$WEBSITE_HOSTNAME bin/bundle exec /root/benchmarks/vendor/bundle/ruby/3.0.0/bin/puma -p 80 -w 0 -t 0:5
