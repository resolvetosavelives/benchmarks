source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

gem "rails", "~> 5.2"

gem "bcrypt", "~> 3.1"
gem "bootsnap", "~> 1.4", require: false
gem "devise", "~> 4.7"
gem "hamlit-rails", "~> 0.2"
gem "pg", "~> 1.2"
gem "puma", "~> 5.2"
gem "rack-attack", "~> 6.5"
gem "rake", "~> 13.0"
gem "rubyXL", "~> 3.4"
gem "sentry-rails", "~> 4.2"
gem "sentry-ruby", "~> 4.2"
gem "webpacker", "~> 5.2"

group :development, :test do
  gem "byebug", "~> 11.1", platforms: %i[mri mingw x64_mingw]
  gem "colorize", "~> 0.8"
  gem "m", "~> 1.5"
  gem "minitest-rails", "~> 5.2"
  gem "pry", "~> 0.13"
  gem "pry-byebug", "~> 3.9"
end

group :development do
  gem "html2haml", "~> 2.2"
  gem "listen", "~> 3.4"
  gem "rails-erd", "~> 1.6"
  gem "spring", "~> 2.1"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.7"
end

group :test do
  gem "capybara", "~> 3.35"
  gem "cuprite", "~> 0.6"
  gem "factory_bot_rails", "~> 6.1"
  gem "minitest-reporters", "~> 1.4"
  gem "mocha", "~> 1.12"
  gem "rails-controller-testing", "~> 1.0"
end
