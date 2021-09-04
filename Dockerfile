# syntax=docker/dockerfile:1
FROM benchmarksbase:latest as base
FROM ruby:3.0.2-alpine

WORKDIR /app
COPY --from=base /usr/local/bundle/ /usr/local/bundle/
COPY --from=base /app /app

# take care to NOT bundle foreman as directed by its author
RUN gem install foreman
EXPOSE 80
ENV RAILS_ENV=production
# NB: we are not using ENTRYPOINT because it does not pass Unix signals
CMD ["foreman", "start", "web"]
