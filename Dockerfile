FROM benchmarksbase:latest as base
FROM ruby:3.0.2-alpine
COPY --from=base /app /app

WORKDIR /app

# TODO: app fails to start without this here, even when in the base image. why?
RUN apk add postgresql-libs

RUN bundle config path /app/vendor/bundle
RUN bundle config without development test
# take care to NOT bundle foreman as directed by its author
RUN gem install foreman

EXPOSE 80

ENV RAILS_ENV=production

# NB: we are not using ENTRYPOINT because it does not pass Unix signals
# CMD ["RAILS_ENV=production bundle", "exec", "rails", "s"]
#CMD bundle exec puma -e production -p 3000 --threads 2:16
CMD ["foreman", "start", "web"]
