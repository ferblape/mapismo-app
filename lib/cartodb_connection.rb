# coding: UTF-8

module MapismoApp
  class CartoDBConnection
    
    attr_accessor :connection
  
    def initialize(connection)
      raise "Connection is required" if connection.nil?
      self.connection = connection
    end
  
    def table_exists?(table_name)
      run_query("SELECT cartodb_id FROM #{table_name} LIMIT 1")
      connection.response.code.to_i == 200
    end

    def create_table(name, schema)
      connection.post("/api/v1/tables", {
        name: name,
        schema: schema
      })
      if connection.response.code.to_i == 200
        return true
      else
        return connection.response
      end
    end

    def reset_table(name)
      run_query("DELETE FROM #{name}")
    end

    def find_row(table_name, condition)
      run_query("SELECT * FROM #{table_name} WHERE #{condition} LIMIT 1")
      if connection.response.code.to_i == 200
        response = JSON.parse(connection.response.body)
        if response["total_rows"].to_i == 0
          return nil
        else
          return response["rows"][0]
        end
      else
        return nil
      end
    end

    def insert_row(table_name, attributes)
      query = convert_to_insert_query(table_name, attributes)
      run_query(query, :post)
      if connection.response.code.to_i == 200
        return true
      else
        return connection.response
      end
    end

    private

    def convert_to_insert_query(name, attributes)
      attributes_list = []
      values_list = []
      attributes.each do |k,v|
        attributes_list << k
        values_list << "'#{v}'"
      end
      return "INSERT INTO #{name} (#{attributes_list.join(',')}) VALUES (#{values_list.join(',')})" 
    end

    def run_query(query, method = :get)
      request = Mapismo.cartodb_api_endpoint + "?q=" + CGI.escape(query)
      connection.send(method, request)
      return connection.response
    end
  
    def load_consumer
      OAuth::Consumer.new(Mapismo.consumer_key, Mapismo.consumer_secret, 
                            {site: Mapismo.cartodb_oauth_endpoint(Mapismo.cartodb_username)})
    end
  end
end