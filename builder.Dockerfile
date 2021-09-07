# syntax=docker/dockerfile:1
FROM ruby:3.0.2-alpine

##
# NB: because this env var APP_HOME is embedded into the container image it
#   can be used in child Dockerfiles as well as ONBUILD instructions.
ENV APP_HOME=/home/app/
WORKDIR $APP_HOME

##
# Add basic packages. Needs to run as root, before any USER directive.
# nodejs-current version expected is 16.x, if this version changes app may encounter errs
RUN apk add --no-cache \
      build-base \
      postgresql-dev \
      git \
      nodejs-current \
      yarn \
      tzdata \
      file

##
# Install Node modules
COPY package.json yarn.lock $APP_HOME
RUN yarn install --non-interactive --production --check-files --frozen-lockfile

##
# install Ruby gems to the default GEM_HOME of /usr/local/bundle from which they must be copied later
COPY Gemfile* .ruby-version $APP_HOME
RUN bundle config set --local path /usr/local/bundle && \
    bundle config set --local deployment true && \
    bundle config set --local clean false \
    bundle install

##
# Subsequent builds check for any gems changes and prunes any unused
ONBUILD COPY Gemfile* .ruby-version $APP_HOME
#ONBUILD RUN bundle config set --local clean true \
#    bundle config set --local deployment true && \
#    bundle install
ONBUILD RUN bundle config set --local path /usr/local/bundle && \
    bundle config set --local deployment true && \
    bundle config set --local clean false \
    bundle install

##
# After updating gems for the child image, copy in the latest app code
# Copy the whole application folder into the image
ONBUILD COPY . $APP_HOME

##
# Compile assets with Webpacker taking care to respect the secret RAILS_MASTER_KEY
# Note that:
#   1. Executing "assets:precompile" runs "yarn install" prior
#   2. Executing "assets:precompile" runs "webpacker:compile", too
#   3. Rails raises a `MissingKeyError` if the master key is missing.
ONBUILD RUN --mount=type=secret,id=RAILS_MASTER_KEY,dst=config/master.key \
    RAILS_ENV=production bundle exec rails assets:precompile
# TODO: make use here of?: assets:clean

##
# Remove folders not needed in resulting image
ONBUILD RUN rm -rf node_modules tmp/cache vendor/bundle test spec app/javascript app/packs
