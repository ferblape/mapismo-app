ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.filter_run_excluding :random_failure
  config.infer_base_class_for_anonymous_controllers = false

  def mocked_response(code)
    response = mock()
    response.stubs(:code).returns(code)
    return response
  end
end
