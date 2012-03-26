# coding: UTF-8

require 'openssl'
require 'base64'

redis = Redis.new

def encode(message)
  algorithm = 'aes-256-cbc'
  password = 'pn3TSvVZX9ONgsDxHGWeDQXV'

  e = nil
  key = Digest::SHA256.digest(password)
  c = OpenSSL::Cipher::Cipher.new(algorithm)
  c.encrypt
  c.key = key
  c.iv = iv = c.random_iv
  e = c.update message
  e << c.final
  "#{Base64.encode64(iv)}|||#{Base64.encode64(e)}"
end

valid_message = {
  cartodb_table_name: 'mapismo_data',
  cartodb_map_id: 4,
  cartodb_username: 'mapismo',
  cartodb_userid: 33,
  cartodb_auth_token: 'YG7v8YrCbJ6nuHhNkhR9s8r7DtH0iu2WXo5FHszH',
  cartodb_auth_secret: 'mdyHGN3avBUEOzyfEPT23IHCD1jKJdhiSaEJcGE1',
  source: 'flickr',
  keyword: 'valencia',
  latitude: 39.4702393,
  longitude: -0.37680490000002465,
  radius: 5000,
  start_date: '2008-03-01+00:00:00',
  end_date: '2012-03-22+23:59:59',
  preview_token: nil
}.to_json

redis.publish "mapismo-dev", encode(valid_message)

valid_message = {
  cartodb_table_name: 'mapismo_data',
  cartodb_map_id: 3,
  cartodb_username: 'mapismo',
  cartodb_userid: 33,
  cartodb_auth_token: 'YG7v8YrCbJ6nuHhNkhR9s8r7DtH0iu2WXo5FHszH',
  cartodb_auth_secret: 'mdyHGN3avBUEOzyfEPT23IHCD1jKJdhiSaEJcGE1',
  source: 'flickr',
  keyword: 'falleras',
  latitude: 39.4702393,
  longitude: -0.37680490000002465,
  radius: 4000,
  start_date: '2012-03-01+00:00:00',
  end_date: '2012-03-22+23:59:59',
  preview_token: nil
}.to_json

redis.publish "mapismo-dev", encode(valid_message)
