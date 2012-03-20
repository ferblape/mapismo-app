# coding: UTF-8

require 'openssl'
require 'base64'

class WorkerNotifier

  def initialize
    @key = Digest::SHA256.digest(Mapismo.workers_password_channel)
  end

  def notify!(message)
    c = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    c.encrypt
    c.key = @key
    c.iv = iv = c.random_iv
    e = c.update(message.to_json)
    e << c.final
    $redis.publish(Mapismo.workers_channel, "#{Base64.encode64(iv)}|||#{Base64.encode64(e)}")
  end

end