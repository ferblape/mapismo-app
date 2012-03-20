# coding: UTF-8

module MapismoApp
  class CartoDBConnection

    attr_accessor :connection

    def initialize(connection)
      raise "Connection is required" if connection.nil?
      @connection = connection
    end

    def table_exists?(table_name)
      run_query("SELECT cartodb_id FROM #{table_name} LIMIT 1")
      connection.response.code.to_i == 200
    end

    def create_table(name, schema, options = {})
      options[:privacy] ||= :private

      table_options = {
        name: name,
        schema: schema
      }
      table_options.merge!({the_geom_type: options[:geometry]}) if options[:geometry]
      connection.post("/api/v1/tables", table_options)
      if connection.response.code.to_i == 200
        if options[:privacy] == :private
          return true
        else
          connection.put("/api/v1/tables/#{name}?privacy=1")
          if connection.response.code.to_i == 200
            return true
          else
            raise_error
          end
        end
      else
        raise_error
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
        raise_error
      end
    end

    def get_id_from_last_record(table_name)
      run_query("SELECT cartodb_id FROM #{table_name} ORDER BY created_at DESC LIMIT 1")
      if connection.response.code.to_i == 200
        response = JSON.parse(connection.response.body)
        if response["total_rows"].to_i == 0
          return nil
        else
          return response["rows"][0]["cartodb_id"]
        end
      else
        return nil
      end
    end

    def run_query(query, method = :get)
      request = Mapismo.cartodb_api_endpoint + "?q=" + CGI.escape(query)
      connection.send(method, request)
      return connection.response
    end

    def add_index_to_table(table_name, column, options = {})
      unique_str = (options[:unique] == true) ? 'UNIQUE ' : ''
      column_sanitized = column.tr(',','_')
      run_query("CREATE #{unique_str}INDEX #{column_sanitized}_idx ON #{table_name} (#{column})")
      if connection.response.code.to_i == 200
        return true
      else
        raise_error
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

    def load_consumer
      OAuth::Consumer.new(Mapismo.consumer_key, Mapismo.consumer_secret,
                            {site: Mapismo.cartodb_oauth_endpoint(Mapismo.cartodb_username)})
    end

    def raise_error
      response = JSON.parse(connection.response.body)
      raise response["error"][0]
    end
  end
end