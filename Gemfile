source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1.0'
gem 'net-smtp', require: false # required on Rails 6 for Ruby 3.1+ support
gem 'net-pop', require: false # required on Rails 6 for Ruby 3.1+ support
gem 'net-imap', require: false # required on Rails 6 for Ruby 3.1+ support
gem 'psych', '< 4' # required on Rails 6 for Ruby 3.1+ support

# Use postgresql as the database for Active Record
gem 'pg'
gem 'terser'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

gem "cssbundling-rails", "~> 1.1"
gem "primer_view_components", "~> 0.14.0"

gem 'puma', '~> 5.6'
gem 'nokogiri'

gem 'responders'

gem 'rack-timeout'

gem 'airbrake', '~> 7.3.5', require: false
gem 'sentry-raven', require: false

gem 'ddtrace', require: false

gem 'rails_semantic_logger', require: false

gem 'devise'
gem 'omniauth-saml'
gem 'omniauth-rails_csrf_protection'

gem 'simple_form'

gem 'kt-paperclip', '~> 7.1'
gem 'aws-sdk-s3'

gem 'attribute_normalizer', '~> 1.2.0'

gem 'foreman'
gem 'delayed_job'
gem 'delayed_job_active_record'

gem 'with_transactional_lock'

gem 'bootsnap', '>= 1.3.0', require: false

# Avoid deprecation notices by pinning mail to Ruby 2.7.5 compatible version
gem 'mail', '~> 2.7.1'

gem 'sprockets-rails'

group :development, :test do
  gem 'simplecov', require: false
  gem 'pry-rails'
  gem 'pry-remote'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails'
  gem 'betterlint'

  gem 'dotenv-rails'

  gem 'site_prism'
  gem 'factory_bot_rails'

  gem 'ruby_spec_helpers', path: 'vendor/gems/ruby_spec_helpers'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 3.3.0'
  gem 'travis', '~> 1.8.0'
  gem 'listen'
end

group :test do
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'db-query-matchers'
end
