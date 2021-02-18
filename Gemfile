source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

gem "rails", "~> 5.2.4.3"
gem "pg"
gem "puma"
gem "bcrypt"
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "rake"
gem "rubyXL"
gem "webpacker", "~> 5.1.1"
gem "devise"
gem "sentry-raven"
gem "rack-attack"
gem "hamlit-rails"
# skylight.io is a performance analysis tool, our free trial expires on 2020-02-29.
gem "skylight"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "m"
  gem "colorize"
  gem "minitest-rails"
end

group :development do
  gem "html2haml"
  gem "listen"
  gem "rails-erd"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara"
  gem "cuprite"
  gem "factory_bot_rails"
  gem "minitest-reporters"
  gem "rails-controller-testing"
  gem "mocha"
end
