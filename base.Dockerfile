FROM ruby:3.0.2-alpine

# RUN apk add build-base postgresql-dev git nodejs yarn tzdata file
RUN apk add build-base postgresql-dev postgresql-libs
RUN apk add nodejs-current yarn
RUN apk add python3
RUN apk add libpq

WORKDIR /app
# Install base app gems/packages into the base image
COPY Gemfile* .ruby-version package.json yarn.lock /app/

# TODO: use the modern version
RUN bundle config without development test
RUN bundle config path /app/vendor/bundle
RUN bundle config set --local deployment 'true'
RUN bundle install

RUN yarn install --frozen-lockfile --production true

# In builds using this as a base, install new gems and remove obsolete gems
ONBUILD RUN bundle config without development test 
ONBUILD RUN bundle config path /app/vendor/bundle
ONBUILD COPY Gemfile* .ruby-version /app/
ONBUILD RUN bundle install --clean


ONBUILD COPY package.json yarn.lock /app/
ONBUILD RUN yarn install --frozen-lockfile

# After updating gems for the child image, copy in the latest app code
ONBUILD COPY . /app

ONBUILD RUN --mount=type=secret,id=RAILS_MASTER_KEY,dst=config/master.key \
    RAILS_ENV=production bundle exec rails assets:precompile

#TODO: Cleanup
# ONBUILD RUN bundle clean --force && \
#     # Remove unneeded files from installed gems (cached *.gem, *.o, *.c)
#     rm -rf /usr/local/bundle/cache/*.gem && \
#     find /usr/local/bundle/gems/ -name "*.c" -delete && \
#     find /usr/local/bundle/gems/ -name "*.o" -delete

# Remove unnecessary packages
ONBUILD RUN apk del build-base postgresql-dev yarn nodejs python3

# Remove folders not needed in resulting image
ONBUILD RUN rm -rf node_modules tmp/cache test spec
