FROM ruby:2.6.3
RUN apt-get update -qq && apt-get install -y nodejs yarnpkg postgresql-client

RUN ln -s /usr/bin/yarnpkg /usr/bin/yarn
RUN yarn global add floki

RUN mkdir /tmp/railsinit
COPY Gemfile /tmp/railsinit
RUN cd /tmp/railsinit && bundle install

COPY dockers/webapp-dev/entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000


CMD ["rails", "server", "-b", "0.0.0.0"]
