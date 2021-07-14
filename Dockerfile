FROM benchmarksbase:latest as base
FROM ruby:3.0.2-alpine
COPY --from=base /app /app

WORKDIR /app
RUN bundle config path /app/vendor/bundle
RUN bundle config without development test
ENV RAILS_ENV=production
# CMD ["RAILS_ENV=production bundle", "exec", "rails", "s"]
CMD bundle exec puma -e production -p 3000 --threads 2:16

