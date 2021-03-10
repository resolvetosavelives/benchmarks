source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

gem "rails", "~> 5.2.4.5"

gem "bcrypt"
gem "bootsnap", require: false
gem "devise"
gem "hamlit-rails"
gem "pg"
gem "puma"
gem "rack-attack"
gem "rake"
gem "rubyXL"
gem "sentry-rails"
gem "sentry-ruby"
gem "webpacker", "~> 5.2"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "colorize"
  gem "m"
  gem "minitest-rails"
  gem "pry"
  gem "pry-byebug"
end

group :development do
  gem "html2haml"
  gem "listen"
  gem "rails-erd"
  gem "spring"
  gem "spring-watcher-listen"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "cuprite"
  gem "factory_bot_rails"
  gem "minitest-reporters"
  gem "mocha"
  gem "rails-controller-testing"
end
