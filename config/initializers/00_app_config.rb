# coding: UTF-8

# Check proper configuration before load environment

unless File.file?("#{Rails.root}/config/app_config.yml")
  raise "Missing configuration file config/app_config.yml"
end

%W{ mapismo_oauth_secret mapismo_oauth_token mapismo_consumer_key mapismo_consumer_secret workers_password_channel}.each do |env_variable|
  if ENV[env_variable].blank?
    raise "Missing environment variable `#{env_variable}`. Set it up before continue."
  end
end

raw_config = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]
APP_CONFIG = raw_config.to_options! unless raw_config.nil?