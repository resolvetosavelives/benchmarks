# syntax=docker/dockerfile:1
FROM ruby:3.0.2-alpine

##
# NB: because this env var APP_HOME is embedded into the container image it
#   can be used in child Dockerfiles as well as ONBUILD instructions.
ENV APP_HOME=/home/app/
WORKDIR $APP_HOME

# Add basic packages
RUN apk add --no-cache \
      postgresql-client \
      tzdata \
      file

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
ONBUILD COPY --from=Builder --chown=app:app /usr/local/bundle/ /usr/local/bundle/
ONBUILD COPY --from=Builder --chown=app:app $APP_HOME $APP_HOME
