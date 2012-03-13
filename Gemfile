source "https://rubygems.org"

gem "rails", "3.2.2"
gem "jquery-rails"
gem "omniauth-oauth"
gem "redis"

group :assets do
  gem "sass-rails",   "~> 3.2.3"
  gem "coffee-rails", "~> 3.2.1"
  gem "uglifier", ">= 1.0.3"
end

group :test do
  gem "rspec"
  gem "capybara"
  gem "mocha"
  gem "selenium"
  gem "selenium-client"
  gem "launchy"
  gem "selenium-webdriver"
  gem "timecop"
end

group :development, :test do
  gem "rspec-rails"
  gem "steak"
  # install Ruby debug for 1.9.3 from here http://fernando.blat.es/post/15361240325/ruby-1-9-3-ruby-debug
  gem "ruby-debug19", require: "ruby-debug"
end
