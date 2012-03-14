# coding: UTF-8

redis = Redis.new

valid_message = {
  cartodb_table_name: 'mapismo_data',
  cartodb_map_id: 1,
  cartodb_username: 'mapismo',
  cartodb_userid: 33,
  cartodb_auth_token: 'YG7v8YrCbJ6nuHhNkhR9s8r7DtH0iu2WXo5FHszH',
  cartodb_auth_secret: 'mdyHGN3avBUEOzyfEPT23IHCD1jKJdhiSaEJcGE1',
  source: 'instagram',
  keyword: '15m',
  latitude: 40.416691,
  longitude: -3.703611,
  radius: 5000,
  start_date: '2011-05-15+00:00:00',
  end_date: '2011-05-15+23:59:59'
}.to_json

require 'openssl'
require 'base64'

algorithm = 'aes-256-cbc'
password = 'pn3TSvVZX9ONgsDxHGWeDQXV'

e = nil
key = Digest::SHA256.digest(password)
c = OpenSSL::Cipher::Cipher.new(algorithm)
c.encrypt
c.key = key
c.iv = iv = c.random_iv
e = c.update valid_message
e << c.final

p "sending: #{Base64.encode64(iv)}|||#{Base64.encode64(e)}"

redis.publish "mapismo-dev", "#{Base64.encode64(iv)}|||#{Base64.encode64(e)}"