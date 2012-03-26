require "spec_helper"
require "steak"
require "capybara/rails"
require "capybara/dsl"
require "selenium/client"
require "selenium"
require "selenium-webdriver"

# Put your acceptance spec helpers inside spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Capybara.default_driver    = :selenium
Capybara.default_wait_time = 30
OmniAuth.config.test_mode = true