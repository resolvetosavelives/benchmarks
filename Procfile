web: bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
web_prod: RAILS_ENV=$RAILS_ENV DATABASE_URL=$DATABASE_URL RAILS_MASTER_KEY=$RAILS_MASTER_KEY APPLICATION_HOST=$APPLICATION_HOST bundle exec puma -p 80 -w 0 -t 0:5
release: bin/rails db:migrate
