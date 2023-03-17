source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.1.0'
gem 'rails', '~> 7.0', '>= 7.0.2.3'

gem 'activerecord-import', '~> 1.3'
gem 'airrecord', '~> 1.0'
gem 'avo', '~> 2.17'
gem 'bcrypt', '~> 3.1'
gem 'bootsnap', '~> 1.11', require: false
gem 'devise', '~> 4.8'
gem 'faker'

gem 'faraday', '~> 1.10.2'
gem 'hamlit', '~> 2.16'
gem 'hamlit-rails', '~> 0.2'
gem 'inline_svg', '~> 1.8'
gem 'interactor-rails', '~> 2.2'
gem 'jwt'
gem 'pg', '~> 1.4'
gem 'puma', '~> 5.6'
# pundit also is depended upon by avo, so this is pinned to Avo's version. prob should update when avo is updated.
gem 'pundit', '~> 2.2.0'
gem 'racc', '1.6.0' # latest version fails on alpine
gem 'rack-attack', '~> 6.5'
gem 'rake', '~> 13.0'
gem 'rexml', '>= 3.2.5'
gem 'rubyXL', '~> 3.4'
gem 'sassc'
gem 'sendgrid-actionmailer', '~> 3.2'
gem 'sentry-rails', '~> 4.9'
gem 'sentry-ruby', '~> 4.9'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets', '~>4.1.1' # fixes for hashes included in files
gem 'sprockets-rails'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

gem 'tzinfo-data'

gem 'kaminari', '~> 1.2'

group :development, :test do
  gem 'm', '~> 1.6'
  gem 'pry-byebug', '~> 3.10'
  gem 'rspec-rails', '~> 5.1'
end

group :development do
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0'
  gem 'html2haml', '~> 2.2'
  gem 'listen', '~> 3.7'
  gem 'pry-rails', '~> 0.3.9'
  gem 'rails-erd', '~> 1.7'
  gem 'web-console', '~> 4.2'
end

group :test do
  gem 'capybara', '~> 3.36'
  gem 'cuprite', '~> 0.11'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'rspec_junit_formatter'
end
