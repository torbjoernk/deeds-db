source 'https://rubygems.org'


gem 'rails', '4.2.6'
gem 'mysql2', '>= 0.3.13', '< 0.5'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'#, '~> 2.0'

gem 'font-awesome-sass', '~> 4.5.0'
gem 'breadcrumbs_on_rails', '>=2.3.0'

gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'simplecov'
  gem 'sauce_whisk'

  gem 'guard-rspec', require: false
  gem 'i18n-tasks', '~> 0.9.5'
  gem 'byebug'
end

group :headfultest do
  gem 'capybara-webkit'
  gem 'launchy'
end

group :development do
  gem 'web-console'#, '~> 2.0'
  gem 'spring'
end

group :ci do
  gem 'rspec_junit_formatter', '0.2.2'
  gem 'coveralls', require: false
  gem 'codeclimate-test-reporter', require: false
end
