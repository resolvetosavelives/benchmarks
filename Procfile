web: RAILS_ENV=${RAILS_ENV:-development} DATABASE_URL=$DATABASE_URL RAILS_MASTER_KEY=$RAILS_MASTER_KEY RAILS_LOG_TO_STDOUT=true RAILS_SERVE_STATIC_FILES=true NO_SSL=true WEBSITE_HOSTNAME=$WEBSITE_HOSTNAME bundle exec puma -p $PORT -t 0:5 -w 3
troubleshoot: echo "PWD: $PWD" && ls -l
release: bin/rails db:migrate
