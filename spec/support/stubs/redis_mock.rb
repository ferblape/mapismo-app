class RedisMock
  def initialize
  end

  def publish(channel, message)
    puts "[#{channel}] >> #{message}"
  end
end