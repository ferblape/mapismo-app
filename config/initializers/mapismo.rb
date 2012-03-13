# coding: UTF-8

class Mapismo
  def self.cartodb_username
    APP_CONFIG[:cartodb_username]
  end
  
  def self.users_table
    APP_CONFIG[:users_table]
  end

  def self.maps_table
    APP_CONFIG[:maps_table]
  end

  def self.data_table
    APP_CONFIG[:data_table]
  end
  
  def self.oauth_token
    ENV['mapismo_oauth_token']
  end
  
  def self.oauth_secret
    ENV['mapismo_oauth_secret']
  end
  
  def self.consumer_key
    ENV['mapismo_consumer_key']
  end

  def self.consumer_secret
    ENV['mapismo_consumer_secret']
  end
  
  def self.cartodb_oauth_endpoint(username)
    if Rails.env.production?
      "https://#{username}.cartodb.com"
    else
      "http://#{username}.localhost.lan:3000"
    end
    "https://#{username}.cartodb.com"
  end

  def self.cartodb_api_endpoint
    "/api/v1/sql"
  end
end

$mapismo_conn = MapismoApp::AdminCartoDBConnection.new