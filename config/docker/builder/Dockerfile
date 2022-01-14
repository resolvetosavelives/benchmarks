# syntax=docker/dockerfile:1.2

##
# with a Dockerfile that specifies use of a BuildKit frontend docker/dockerfile:1.2, the secret can be accessed when performing a RUN
# https://docs.docker.com/develop/develop-images/build_enhancements/
##

##
# Prep phase.
# Add basic packages. Needs to run as root, before any USER directive.
# nodejs-current version expected is 16.x, if this version changes app may encounter errs
FROM ruby:3.0.3-alpine
# the nodejs package means the current LTS version which now is 16.13.1 and requires python3
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    git \
    python3 \
    nodejs \
    yarn \
    tzdata \
    file

WORKDIR /app

COPY Gemfile* .ruby-version yarn.lock package.json /app/

RUN yarn install --non-interactive --production --check-files --frozen-lockfile

ENV BUNDLE_PATH=/app/vendor/bundle
RUN bundle config set --local path $BUNDLE_PATH && \
    bundle config set --local disable_shared_gems true && \
    bundle config set --local path.system false && \
    bundle config set --local clean false && \
    bundle config set --local deployment true && \
    bundle config set --local bin true && \
    bundle install -j4 --retry 3

# Subsequent builds check for any gems changes and prunes any unused
ONBUILD WORKDIR /app
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle config set --local path $BUNDLE_PATH && \
    bundle config set --local disable_shared_gems true && \
    bundle config set --local path.system false && \
    bundle config set --local clean false && \
    bundle config set --local deployment true && \
    bundle config set --local bin true && \
    bundle install -j4 --retry 3 && \
    bundle clean --force

##
# Compile assets with Webpacker taking care to respect the secret RAILS_MASTER_KEY
# Note that:
#   1. Executing "assets:precompile" runs "yarn install" prior
#   2. Executing "assets:precompile" runs "webpacker:compile", too
#   3. Rails raises a `MissingKeyError` if the master key is missing.
# NB: this use of "--mount=type=secret" depends on Docker BuildKit being enabled
ONBUILD RUN --mount=type=secret,id=RAILS_MASTER_KEY,dst=config/master.key \
    RAILS_ENV=production bundle exec rails assets:precompile

##
# Remove folders not needed in resulting image
#ONBUILD RUN rm -rf node_modules tmp/cache vendor/bundle test spec app/javascript app/packs
