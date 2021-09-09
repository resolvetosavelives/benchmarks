web: bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
web_prod: RAILS_ENV=$RAILS_ENV DATABASE_URL=$DATABASE_URL RAILS_MASTER_KEY=$RAILS_MASTER_KEY NO_SSL=true WEBSITE_HOSTNAME=$WEBSITE_HOSTNAME bundle exec puma -p 80 -w 0 -t 0:5
troubleshoot: echo `whoami` && touch /root/can-write && ls -l /root/can-write
release: bin/rails db:migrate
