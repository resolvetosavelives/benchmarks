web: bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
web_prod: RAILS_ENV=${RAILS_ENV:-production} DATABASE_URL=$DATABASE_URL RAILS_MASTER_KEY=$RAILS_MASTER_KEY NO_SSL=true WEBSITE_HOSTNAME=$WEBSITE_HOSTNAME bundle exec puma -p 80 -w 0 -t 0:5
troubleshoot: echo "PWD: $PWD" && ls -l
release: bin/rails db:migrate
