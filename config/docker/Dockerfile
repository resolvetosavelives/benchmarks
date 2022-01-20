# syntax=docker/dockerfile:1

ARG BUILDER_IMAGE=benchmarks_builder:latest
FROM $BUILDER_IMAGE AS Builder

FROM ruby:3.0.3-alpine

ENV RAILS_ENV production

# Add basic packages
RUN apk add --no-cache \
    postgresql-client \
    tzdata \
    file

# Workaround to trigger Builder's ONBUILDs to finish:
COPY --from=Builder /etc/alpine-release /tmp/dummy

##
# Add user
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app

# Copy app with gems from former build stage
COPY --from=Builder --chown=app:app /app /app
USER app
WORKDIR /app
RUN mkdir -p tmp/pids

EXPOSE 80

# there was nothing to remove here once, so maybe these should go away?
RUN rm -f public/packs/css/*.gz
RUN rm -f public/packs/css/*.br

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
