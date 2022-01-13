# syntax=docker/dockerfile:1

FROM ihrbenchmarkwhoproduction.azurecr.io/benchmarks_builder:latest AS Builder
# for working locally, use this FROM line instead of the one above:
#FROM benchmarks_builder:latest AS Builder

FROM ruby:3.0.3-alpine

# Add basic packages
RUN apk add --no-cache \
    postgresql-client \
    tzdata \
    file

##
# NB: because ENV vars are embedded into the container image they
#   can be used in child Dockerfiles as well as ONBUILD instructions.
ENV USER_HOME=/root
ENV REPO_HOME=$USER_HOME/benchmarks
# this section of vars for bundler and gems is the hard part of this
ENV BUNDLE_PATH=$REPO_HOME/vendor/bundle
ENV BUNDLE_APP_CONFIG=$REPO_HOME/.bundle
ENV BUNDLE_CONFIG=$BUNDLE_APP_CONFIG/config
ENV GEM_HOME=$BUNDLE_PATH
ENV GIT_REPO=https://github.com/resolvetosavelives/benchmarks.git
ENV GIT_BRANCH=main
ENV RAILS_ENV production



# Workaround to trigger Builder's ONBUILDs to finish:
COPY --from=Builder /etc/alpine-release /tmp/dummy
## Someday..
#ONBUILD ARG COMMIT_SHA
#ONBUILD ARG COMMIT_TIME
#ONBUILD ARG TAG_OR_BRANCH
#ONBUILD ENV COMMIT_SHA ${COMMIT_SHA}
#ONBUILD ENV COMMIT_TIME ${COMMIT_TIME}
#ONBUILD ENV TAG_OR_BRANCH ${TAG_OR_BRANCH}

##
# Add user
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app

# Copy app with gems from former build stage
# TODO: update this comment: this is intended to copy /home/app/benchmarks and /home/app/bundle
#ONBUILD COPY --from=Builder /usr/local/bundle/ /usr/local/bundle/
#ONBUILD COPY --from=Builder /root/.bundle/config /root/.bundle/config
#ONBUILD COPY --from=Builder --chown=app:app $BUNDLE_CONFIG $BUNDLE_CONFIG
COPY --from=Builder $USER_HOME/ $USER_HOME/

WORKDIR $REPO_HOME
# take care to NOT bundle foreman as directed by its author
#ONBUILD RUN bin/bundle exec gem install foreman
EXPOSE 80

#ONBUILD USER app:app
# need to be user app for mkdir else root owns it which is a problem at runtime
RUN mkdir -p tmp/pids

RUN rm public/packs/css/*.gz
RUN rm public/packs/css/*.br
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
