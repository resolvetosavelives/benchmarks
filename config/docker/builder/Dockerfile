# syntax=docker/dockerfile:1.2

##
# with a Dockerfile that specifies use of a BuildKit frontend docker/dockerfile:1.2, the secret can be accessed when performing a RUN
# https://docs.docker.com/develop/develop-images/build_enhancements/
##

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
ENV USER_HOME=/root
ENV REPO_HOME=$USER_HOME/benchmarks
# this section of vars for bundler and gems is the hard part of this
ENV BUNDLE_PATH=$REPO_HOME/vendor/bundle
ENV BUNDLE_APP_CONFIG=$REPO_HOME/.bundle
ENV BUNDLE_CONFIG=$BUNDLE_APP_CONFIG/config
ENV GEM_HOME=$BUNDLE_PATH
ENV GIT_REPO=https://github.com/resolvetosavelives/benchmarks.git
ENV GIT_BRANCH=automate-docker-image-builds-with-acr-from-the-pipeline--179500509

WORKDIR $USER_HOME
# pull down the code from the repo and switch to the specified branch
RUN git clone $GIT_REPO benchmarks && \
    cd benchmarks && \
    git checkout $GIT_BRANCH
WORKDIR $REPO_HOME
# Install Node modules
RUN yarn install --non-interactive --production --check-files --frozen-lockfile
# install Ruby gems to the default GEM_HOME of /usr/local/bundle from which they must be copied later
RUN cd $REPO_HOME && \
        bin/bundle config set --local path $BUNDLE_PATH && \
        bin/bundle config set --local disable_shared_gems true && \
        bin/bundle config set --local path.system false && \
        bin/bundle config set --local clean false && \
        bin/bundle config set --local deployment true && \
        bin/bundle config set --local bin true && \
        bin/bundle install
# Subsequent builds check for any gems changes and prunes any unused
ONBUILD WORKDIR $REPO_HOME
ONBUILD RUN cd $REPO_HOME && \
            git pull && \
            git checkout $GIT_BRANCH
ONBUILD RUN cd $REPO_HOME && \
        bin/bundle config set --local path $BUNDLE_PATH && \
        bin/bundle config set --local disable_shared_gems true && \
        bin/bundle config set --local path.system false && \
        bin/bundle config set --local clean false && \
        bin/bundle config set --local deployment true && \
        bin/bundle config set --local bin true && \
        bin/bundle install

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
