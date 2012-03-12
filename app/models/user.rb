# coding: UTF-8

class User
  
  def initialize(attributes)
    @id = attributes[:id]
    @username = attributes[:username]
    @token = attributes[:token]
    @secret = attributes[:secret]
  end

  def self.find(user_id)
    if row = $mapismo_conn.find_row(Mapismo.users_table, "cartodb_user_id = #{user_id.to_i}")
      new({
        id: row["cartodb_user_id"],
        username: row["cartodb_username"],
        token: row["oauth_token"],
        secret: row["oauth_secret"]
      })
    else
      nil
    end
  end

  def self.create(attributes)
    if $mapismo_conn.insert_row(Mapismo.users_table, {
        cartodb_user_id: attributes[:id],
        cartodb_username: attributes[:username],
        oauth_token: attributes[:token],
        oauth_secret: attributes[:secret]
      })
      
      user = new(attributes)
      user.setup_cartodb_tables!
      user
    else
      raise "Error creating user #{$!}"
    end
  end
  
  def username
    @username
  end
  
  def setup_cartodb_tables!
    connection.create_table("mapismo_maps", "cartodb_user_id integer, name varchar")
    connection.create_table("mapismo_data", "cartodb_user_id integer, map_id integer")
  end
  
  private
  
  def connection
    @connection ||= begin
      consumer = OAuth::Consumer.new(Mapismo.consumer_key, Mapismo.consumer_secret,
                                      {site: Mapismo.cartodb_oauth_endpoint(@username)})
      connection = OAuth::AccessToken.new(consumer, @token, @secret)
      MapismoApp::CartoDBConnection.new(connection)
    end
  end

end