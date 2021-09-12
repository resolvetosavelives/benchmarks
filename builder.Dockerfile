# syntax=docker/dockerfile:1

##
# Prep phase.
# Add basic packages. Needs to run as root, before any USER directive.
# nodejs-current version expected is 16.x, if this version changes app may encounter errs
FROM ruby:3.0.2-alpine
RUN apk add --no-cache \
      build-base \
      postgresql-dev \
      git \
      nodejs-current \
      yarn \
      tzdata \
      file

##
# NB: because ENV vars are embedded into the container image they
#   can be used in child Dockerfiles as well as ONBUILD instructions.
#ENV APP_HOME=/home/app
ENV APP_HOME=/root
ENV REPO_HOME=$APP_HOME/benchmarks
ENV BUNDLE_PATH=/tmp/bundle
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_CONFIG=/tmp/config
ENV GEM_PATH=$BUNDLE_PATH
ENV GEM_HOME=$BUNDLE_PATH
#ENV GIT_REPO=git@github.com:resolvetosavelives/benchmarks.git
ENV GIT_REPO=https://github.com/resolvetosavelives/benchmarks.git
ENV GIT_BRANCH=another-round-of-troubleshooting-the-container-launch--179500605

RUN mkdir -p $BUNDLE_PATH
RUN touch $BUNDLE_CONFIG
WORKDIR $APP_HOME
# pull down the code from the repo and switch to the specified branch
RUN git clone $GIT_REPO benchmarks && \
    cd benchmarks && \
    git checkout $GIT_BRANCH
WORKDIR $REPO_HOME
# Install Node modules
RUN yarn install --non-interactive --production --check-files --frozen-lockfile
# install Ruby gems to the default GEM_HOME of /usr/local/bundle from which they must be copied later
RUN cd $REPO_HOME && \
        bundle config set --local path $BUNDLE_PATH && \
        bundle config set --local clean false && \
        bundle config set --local deployment true && \
        bundle install
# Subsequent builds check for any gems changes and prunes any unused
ONBUILD WORKDIR $REPO_HOME
ONBUILD RUN cd $REPO_HOME && \
            git pull && \
            git checkout $GIT_BRANCH
ONBUILD RUN cd $REPO_HOME && \
            bundle config set --local path $BUNDLE_PATH && \
            bundle config set --local clean true && \
            bundle config set --local deployment false && \
            bundle install

##
# Compile assets with Webpacker taking care to respect the secret RAILS_MASTER_KEY
# Note that:
#   1. Executing "assets:precompile" runs "yarn install" prior
#   2. Executing "assets:precompile" runs "webpacker:compile", too
#   3. Rails raises a `MissingKeyError` if the master key is missing.
# TODO: this use of --mount apparently depends on BuildKit, and Azure Container Reg (ACR) says that
#   BuildKit is not enabled. may need to either enable BuildKit on ACR, or rework how this secret is handled.
ONBUILD RUN --mount=type=secret,id=RAILS_MASTER_KEY,dst=config/master.key \
    RAILS_ENV=production bundle exec rails assets:precompile

##
# Remove folders not needed in resulting image
#ONBUILD RUN rm -rf node_modules tmp/cache vendor/bundle test spec app/javascript app/packs
