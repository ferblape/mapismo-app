require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "sprockets/railtie"

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

require File.expand_path('../../lib/cartodb_oauth', __FILE__)

module MapismoApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    config.encoding = "utf-8"

    config.filter_parameters += [:password]

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Precompiled javascripts
    config.assets.precompile += ['map.js']

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    config.middleware.use OmniAuth::Builder do
      provider OmniAuth::Strategies::CartoDb, Mapismo.consumer_key, Mapismo.consumer_secret, 
             client_options: {site: Mapismo.cartodb_oauth_endpoint(Mapismo.cartodb_username)}, name: "cartodb"
    end
    
    config.generators do |g|
      g.orm             nil
      g.template_engine :erb
      g.test_framework  :rspec, fixture: false
      g.stylesheets     false
      g.javascripts     false
      g.helpers         false
    end
    
  end
end

require "cartodb_connection"
require "admin_cartodb_connection"