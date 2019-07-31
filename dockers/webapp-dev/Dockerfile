FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

RUN mkdir /tmp/railsinit
COPY Gemfile /tmp/railsinit
RUN touch /tmp/railsinit/
RUN cd /tmp/railsinit && bundle install

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000


CMD ["rails", "server", "-b", "0.0.0.0"]
