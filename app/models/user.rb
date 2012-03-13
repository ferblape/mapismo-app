# coding: UTF-8

class User
  
  attr_reader :id, :username
  
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
  
  def setup_cartodb_tables!
    maps_table_schema = "name varchar, sources varchar, keywords varchar, start_date varchar," + 
                        "end_date varchar, radius integer, location_name varchar, lat float, lon float"
    connection.create_table(Mapismo.maps_table, maps_table_schema)
    connection.create_table(Mapismo.data_table, "cartodb_user_id integer, map_id integer")
  end
  
  def maps
    connection.run_query("SELECT * from #{Mapismo.maps_table} ORDER BY created_at DESC")
    if connection.response.code.to_i == 200
      response = JSON.parse(connection.response.body)
      if response["total_rows"].to_i > 0
        response["rows"].map do |row|
          Map.new(Map.row_to_attributes(row, self))
        end
      else
        []
      end
    else
      []
    end
  end
  
  def get_connection
    connection
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