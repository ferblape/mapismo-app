# coding: UTF-8

namespace :mapismo do
  namespace :setup do
    
    desc "Create, if not exists users table in CartoDB"
    task :create_users_table => :environment do
      unless $mapismo_conn.table_exists?(Mapismo.users_table)
        puts "Table #{Mapismo.users_table} is going to be created with the following schema:"
        puts " - cartodb_user_id: <integer>"
        puts " - cartodb_username: <string>"
        puts " - oauth_token: <string>"
        puts " - oauth_secret: <string>"
        puts " - data_table_id: <integer>"
        if $mapismo_conn.create_table(Mapismo.users_table, "cartodb_user_id integer, cartodb_username varchar, oauth_token varchar, oauth_secret varchar, data_table_id integer")
          puts "[OK] Table #{Mapismo.users_table} created successfully"
        else
          puts "[ERROR] #{response.body.inspect}"
        end
      else
        puts "[OK] #{Mapismo.users_table} already exists"
      end
    end
    
    desc "Reset users table"
    task :reset_users_table => :environment do
      if $mapismo_conn.table_exists?(Mapismo.users_table)
        if $mapismo_conn.reset_table(Mapismo.users_table)
          puts "[OK] #{Mapismo.users_table} data has been removed"
        else
          puts "[ERROR] #{response.body.inspect}"
        end
      else
        raise "Users table #{Mapismo.users_table} does not exist. You should create it first"
      end
    end
    
  end
end