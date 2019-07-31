FROM ubuntu:19.04
MAINTAINER savanni@cloudcity.io

RUN apt-get update
RUN apt-get install curl nodejs
RUN curl -sSL https://get.rvm.io | bash -s stable --rails

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
ENTRYPOINT ["entrypoint.sh"]
