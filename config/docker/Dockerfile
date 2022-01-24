# syntax=docker/dockerfile:1

ARG BUILDER_IMAGE=benchmarks_builder:latest
FROM $BUILDER_IMAGE AS Builder

FROM ruby:3.0.3-alpine

RUN apk add --no-cache \
    postgresql-client \
    tzdata \
    file

# Configure Rails
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true

WORKDIR /app

EXPOSE 3000

# Workaround to trigger Builder's ONBUILDs to finish:
# COPY --from=Builder /etc/alpine-release /tmp/dummy

# Add user
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app
USER app

# Copy app with gems from former build stage
ONBUILD COPY --from=Builder --chown=app:app /usr/local/bundle/ /usr/local/bundle/
COPY --from=Builder --chown=app:app /app /app

# NB: we are not using ENTRYPOINT because it does not pass Unix signals
# Ok, forget that, I think we should try it.
RUN chmod +x entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

ENV WEBSITE_HOSTNAME $WEBSITE_HOSTNAME
RUN bundle config

CMD DATABASE_URL=$DATABASE_URL RAILS_MASTER_KEY=$RAILS_MASTER_KEY bundle exec rake db:schema:load db:migrate db:seed && \
    bundle exec rails server -b 0.0.0.0
# CMD ["rails", "server", "-b", "0.0.0.0"]
