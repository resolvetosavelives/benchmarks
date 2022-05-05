# syntax=docker/dockerfile:1
# This multi stage dockerfile is borrowed heavily from:
# https://github.com/ledermann/docker-rails-base
# I didn't choose to rely on it directly to avoid a dependency we don't control.

##
# Prep phase.
# Add basic packages. Needs to run as root, before any USER directive.
# nodejs-current version expected is 16.x, if this version changes app may encounter errs
FROM ruby:3.1.2-alpine
# the nodejs package means the current LTS version which now is 16.13.1 and requires python3
RUN apk add --no-cache \
    build-base \
    gcompat \
    postgresql-dev \
    python3 \
    nodejs \
    yarn \
    tzdata \
    file

ENV RAILS_ENV production

WORKDIR /app
COPY package.json yarn.lock /app/
RUN yarn install --non-interactive --production --check-files --frozen-lockfile

# Install standard gems
COPY Gemfile* /app/
ENV BUNDLE_BIN true
ENV BUNDLE_FROZEN true
ENV BUNDLE_WITHOUT "test development"
RUN bundle install -j4 --retry 3

#### ONBUILD: Add triggers to the image, executed later while building a child image

# Install Ruby gems (for production only)
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle install -j4 --retry 3 && \
    # Remove unneeded gems
    bundle clean --force && \
    # Remove unneeded files from installed gems (cache, *.o, *.c)
    rm -rf /usr/local/bundle/cache && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete

ONBUILD COPY . /app

# Compile assets with Webpacker or Sprockets
#
# Notes:
#   1. Executing "assets:precompile" runs "webpacker:compile", too
#   2. For an app using encrypted credentials, Rails raises a `MissingKeyError`
#      if the master key is missing. Because on CI there is no master key,
#      we hide the credentials while compiling assets (by renaming them before and after)
#   3. ASSET_COMPILATION=true manually skips loading credentials so precompile works.
#
ONBUILD RUN mv config/credentials.yml.enc config/credentials.yml.enc.bak 2>/dev/null || true
ONBUILD RUN mv config/credentials config/credentials.bak 2>/dev/null || true
ONBUILD RUN yarn install
ONBUILD RUN ASSET_COMPILATION=true \
    SECRET_KEY_BASE=dummy \
    RAILS_MASTER_KEY=dummy \
    bin/rails assets:precompile
ONBUILD RUN mv config/credentials.yml.enc.bak config/credentials.yml.enc 2>/dev/null || true
ONBUILD RUN mv config/credentials.bak config/credentials 2>/dev/null || true

# Remove folders not needed in resulting image
ONBUILD RUN rm -rf node_modules tmp/cache vendor/bundle test spec app/javascript app/packs
