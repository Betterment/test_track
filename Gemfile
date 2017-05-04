source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 4.2.7', '< 5'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'puma', '~> 2.14'
gem 'nokogiri'

gem 'responders'

gem 'rack-timeout'

gem 'airbrake', '4.1.0'

gem 'le'

gem 'newrelic_rpm'

gem 'devise', '>= 3.5.4', '< 4'
gem 'omniauth-saml'

gem 'simple_form'

gem 'paperclip', '~> 5.0.0'
gem 'aws-sdk', '~> 2.3.0'

gem 'attribute_normalizer', '~> 1.2.0'
gem 'style_closet', path: 'vendor/gems/style-closet'

gem 'foreman'
gem 'delayed_job'
gem 'delayed_job_active_record'

group :development, :test do
  gem 'simplecov', require: false
  gem 'pry-rails'
  gem 'pry-remote'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails'
  gem 'rubocop'

  gem 'dotenv-rails'

  gem 'poltergeist'
  gem 'site_prism'
  gem 'selenium-webdriver'
  gem 'database_cleaner'

  gem 'factory_girl'
  gem 'factory_girl_rails'

  gem 'ruby_spec_helpers', path: 'vendor/gems/ruby_spec_helpers'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'travis', '~> 1.8.0'
end

group :test do
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'db-query-matchers'
end
