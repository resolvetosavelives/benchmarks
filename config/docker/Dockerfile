# syntax=docker/dockerfile:1

ARG BUILDER_IMAGE=benchmarks_builder:latest
FROM $BUILDER_IMAGE AS Builder

FROM ruby:3.0.3-alpine

RUN apk add --no-cache \
    build-base \
    gcompat \
    postgresql-client \
    tzdata \
    file

# Configure Rails
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV WEBSITE_HOSTNAME $WEBSITE_HOSTNAME

WORKDIR /app

EXPOSE 3000

# Add user
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app
USER app

# Copy app with gems from former build stage
COPY --from=Builder --chown=app:app /usr/local/bundle/ /usr/local/bundle/
COPY --from=Builder --chown=app:app /app /app

# NB: we are not using ENTRYPOINT because it does not pass Unix signals
# ... but why do we need unix signals?
RUN chmod +x docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]

RUN bundle config
RUN printenv

CMD ["rails", "server", "-b", "0.0.0.0"]
