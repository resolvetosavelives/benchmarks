# syntax=docker/dockerfile:1

# FROM ihrbenchmarkwhoproduction.azurecr.io/benchmarks_builder:latest AS Builder
# for working locally, use this FROM line instead of the one above:
FROM benchmarks_builder:latest AS Builder

FROM ruby:3.0.3-alpine

# Add basic packages
RUN apk add --no-cache \
    postgresql-client \
    tzdata \
    file

# this section of vars for bundler and gems is the hard part of this
ENV RAILS_ENV production

# Workaround to trigger Builder's ONBUILDs to finish:
# TODO: is this necessary?
COPY --from=Builder /etc/alpine-release /tmp/dummy

##
# Add user

# Copy app with gems from former build stage
COPY --from=Builder /app/ /app/

RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app
RUN chown app:app /app
USER app:app
WORKDIR /app

# take care to NOT bundle foreman as directed by its author
#ONBUILD RUN bin/bundle exec gem install foreman
EXPOSE 80

# need to be user app for mkdir else root owns it which is a problem at runtime
RUN mkdir -p tmp/pids

RUN rm -f public/packs/css/*.gz
RUN rm -f public/packs/css/*.br
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
