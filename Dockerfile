FROM benchmarksbase:latest as base
FROM ruby:alpine
COPY --from=base /app /app

WORKDIR /app
RUN bundle config path /app/vendor/bundle
CMD ["bundle", "exec", "rails", "s"]

