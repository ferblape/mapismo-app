# coding: UTF-8

class User

  attr_reader :id, :username, :token, :secret, :data_table_id

  def initialize(attributes)
    @id = attributes[:id]
    @username = attributes[:username]
    @token = attributes[:token]
    @secret = attributes[:secret]
    @data_table_id = attributes[:data_table_id].to_i
  end

  def self.find(user_id)
    if row = $mapismo_conn.find_row(Mapismo.users_table, "cartodb_user_id = #{user_id.to_i}")
      new({
        id: row["cartodb_user_id"],
        username: row["cartodb_username"],
        token: row["oauth_token"],
        secret: row["oauth_secret"],
        data_table_id: row["data_table_id"]
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
        oauth_secret: attributes[:secret],
        data_table_id: 0
      })

      user = new(attributes)
      user.setup_cartodb_tables!
      user.update_data_table_id!

      user
    else
      raise "Error creating user #{$!}"
    end
  end

  def setup_cartodb_tables!
    maps_table_schema = "name varchar, sources varchar, keywords varchar, start_date varchar," +
                        "end_date varchar, radius integer, location_name varchar, lat float, lon float"
    connection.create_table(Mapismo.maps_table, maps_table_schema)

    data_table_schema = "map_id integer, avatar_url varchar, username varchar, date timestamp," +
                        "permalink varchar, data varchar, the_geom geometry, source varchar," +
                        "source_id varchar"
    connection.create_table(Mapismo.data_table, data_table_schema, {privacy: :public, geometry: 'Point'})
    connection.add_index_to_table(Mapismo.data_table, "date")
    connection.add_index_to_table(Mapismo.data_table, "map_id")
    connection.add_index_to_table(Mapismo.data_table, "source")
    connection.add_index_to_table(Mapismo.data_table, "source_id")
    connection.add_index_to_table(Mapismo.data_table, "map_id,source,source_id", unique: true)
  end

  def maps
    connection.run_query("SELECT * from #{Mapismo.maps_table} ORDER BY created_at DESC")
    if connection.connection.response.code.to_i == 200
      response = JSON.parse(connection.connection.response.body)
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

  def update_data_table_id!
    connection.connection.get("/api/v1/tables")
    if connection.connection.response.code.to_i == 200
      tables = JSON.parse(connection.connection.response.body)["tables"]
      id = tables.select{ |t| t["name"] == Mapismo.data_table }.first["id"]
      $mapismo_conn.run_query("UPDATE #{Mapismo.users_table} SET data_table_id = #{id} WHERE cartodb_user_id = #{self.id}")
      if $mapismo_conn.connection.response.code.to_i == 200
        return true
      else
        response = JSON.parse($mapismo_conn.connection.response.body)
        raise response["error"][0]
      end
    else
      response = JSON.parse(connection.response.body)
      raise response["error"][0]
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