# syntax=docker/dockerfile:1
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
ENV GIT_BRANCH=automate-docker-image-builds-with-acr-from-the-pipeline--179500509
ENV RAILS_ENV production

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
# TODO: update this comment: this is intended to copy /home/app/benchmarks and /home/app/bundle
#ONBUILD COPY --from=Builder /usr/local/bundle/ /usr/local/bundle/
#ONBUILD COPY --from=Builder /root/.bundle/config /root/.bundle/config
#ONBUILD COPY --from=Builder --chown=app:app $BUNDLE_CONFIG $BUNDLE_CONFIG
ONBUILD COPY --from=Builder $USER_HOME/ $USER_HOME/

ONBUILD WORKDIR $REPO_HOME
# take care to NOT bundle foreman as directed by its author
#ONBUILD RUN bin/bundle exec gem install foreman
ONBUILD EXPOSE 80

#ONBUILD USER app:app
# need to be user app for mkdir else root owns it which is a problem at runtime
ONBUILD RUN mkdir -p tmp/pids
