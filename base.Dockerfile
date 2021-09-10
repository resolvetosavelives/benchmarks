# syntax=docker/dockerfile:1
FROM ruby:3.0.2-alpine

# Add basic packages
RUN apk add --no-cache \
      postgresql-client \
      tzdata \
      file

##
# NB: because ENV vars are embedded into the container image they
#   can be used in child Dockerfiles as well as ONBUILD instructions.
#ENV APP_HOME=/home/app
ENV APP_HOME=/root
ENV REPO_HOME=$APP_HOME/benchmarks
ENV BUNDLE_PATH=/tmp/bundle
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_CONFIG=/tmp/config
ENV GIT_REPO=https://github.com/resolvetosavelives/benchmarks.git
ENV GIT_BRANCH=troubleshoot-container-launch-in-app-service--179344790

RUN mkdir -p $BUNDLE_PATH
RUN touch $BUNDLE_CONFIG
WORKDIR $APP_HOME

# Configure Rails
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_ENV production
# TODO: Note from Azure: /home/LogFiles directory, which is used to store the Docker and container logs.

# take care to NOT bundle foreman as directed by its author
RUN gem install foreman
EXPOSE 80

## Someday..
#ONBUILD ARG COMMIT_SHA
#ONBUILD ARG COMMIT_TIME
#ONBUILD ARG TAG_OR_BRANCH
#ONBUILD ENV COMMIT_SHA ${COMMIT_SHA}
#ONBUILD ENV COMMIT_TIME ${COMMIT_TIME}
#ONBUILD ENV TAG_OR_BRANCH ${TAG_OR_BRANCH}

##
# Add user
ONBUILD RUN addgroup -g 1000 -S app && \
            adduser -u 1000 -S app -G app

# Copy app with gems from former build stage
#ONBUILD COPY --from=Builder --chown=app:app $BUNDLE_PATH $BUNDLE_PATH
# this is intended to copy /home/app/benchmarks and /home/app/bundle
ONBUILD COPY --from=Builder --chown=app:app $BUNDLE_PATH/ $BUNDLE_PATH/
ONBUILD COPY --from=Builder --chown=app:app $BUNDLE_CONFIG $BUNDLE_CONFIG
ONBUILD COPY --from=Builder $APP_HOME/ $APP_HOME/

ONBUILD WORKDIR $REPO_HOME
#ONBUILD USER app:app
# need to be user app for mkdir else root owns it which is a problem at runtime
ONBUILD RUN mkdir -p tmp/pids
