# syntax=docker/dockerfile:1
FROM ruby:3.0.2-alpine

##
# system-level build deps
RUN apk add \
    build-base \
    postgresql-dev \
    postgresql-libs \
    libpq \
    nodejs-current \
    yarn \
    python3

WORKDIR /app

##
# Install base app gems into the base image
COPY Gemfile* .ruby-version package.json yarn.lock /app/
RUN yarn install --frozen-lockfile
RUN bundle config --local frozen 1 && \
    bundle install -j4 --retry 3

##
# Install Ruby gems (for production only)
ONBUILD COPY Gemfile* .ruby-version package.json yarn.lock /app/
ONBUILD RUN bundle config --local without 'development test' && \
            bundle install -j4 --retry 3 && \
            # Remove unneeded gems
            bundle clean --force && \
            # Remove unneeded files from installed gems (cached *.gem, *.o, *.c)
            rm -rf /usr/local/bundle/cache/*.gem && \
            find /usr/local/bundle/gems/ -name "*.c" -delete && \
            find /usr/local/bundle/gems/ -name "*.o" -delete
# After updating gems for the child image, copy in the latest app code
ONBUILD COPY . /app

##
# Compile assets with Webpacker taking care to respect the secret RAILS_MASTER_KEY
# Note that:
#   1. Executing "assets:precompile" runs "yarn:install" prior
#   2. Executing "assets:precompile" runs "webpacker:compile", too
#   3. Rails raises a `MissingKeyError` if the master key is missing.
ONBUILD RUN --mount=type=secret,id=RAILS_MASTER_KEY,dst=config/master.key \
    RAILS_ENV=production bundle exec rails assets:precompile

##
# Remove folders not needed in resulting image
ONBUILD RUN rm -rf node_modules tmp/cache vendor/bundle test spec app/javascript app/packs
