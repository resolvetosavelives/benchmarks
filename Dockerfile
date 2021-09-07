# syntax=docker/dockerfile:1

FROM whoihrbenchmarksregistry.azurecr.io/benchmarks_builder:latest AS Builder
#FROM benchmarks_builder:latest AS Builder # for working locally
FROM whoihrbenchmarksregistry.azurecr.io/benchmarks_base:latest AS Base
#FROM benchmarks_base:latest AS Base # for working locally

# Workaround to trigger Builder's ONBUILDs to finish:
COPY --from=Builder /etc/alpine-release /tmp/dummy
WORKDIR $APP_HOME

##
# set USER last cuz most other commanded needed to run as root, but we want to run server as non-root
USER app:app
# NB: we are not using ENTRYPOINT because it does not pass Unix signals
CMD echo "WHO: `whoami`, APP_HOME: $APP_HOME" && ls -la /usr/local/bundle && cd $APP_HOME && echo "PWD: `pwd`" && ls -la && foreman start web_prod
