# syntax=docker/dockerfile:1

#ARG TARGET_DIR=/home/app

# Builder stage
FROM benchmarks_builder:latest AS Builder
# Base stage
FROM benchmarks_base:latest AS Base

##
# set the user and home to avoid mixups with paths and to run as non-root
USER app
WORKDIR /home/app

# Workaround to trigger Builder's ONBUILDs to finish:
COPY --from=Builder /etc/alpine-release /tmp/dummy

# take care to NOT bundle foreman as directed by its author
RUN gem install foreman
EXPOSE 80
ENV RAILS_ENV production
# NB: we are not using ENTRYPOINT because it does not pass Unix signals
CMD ["foreman", "start", "web_prod"]
