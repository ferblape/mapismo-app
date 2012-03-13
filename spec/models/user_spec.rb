# coding: UTF-8

require 'spec_helper'

describe 'User' do
  
  let(:subject) do 
    User.new({
      id: 1,
      username: 'blat',
      token: 'token',
      secret: 'secret'
    })
  end
  
  it "should have an attribute id" do
    subject.id.should == 1
  end
  
  it "should have an attribute username" do
    subject.username.should == 'blat'
  end
  
  describe '.find' do
    it "should return an instance of user with the values of the row if exists" do
      row = {
        "cartodb_user_id" => 1,
        "cartodb_username" => "blat",
        "oauth_token" => "token",
        "oauth_secret" => "secret"
      }
      $mapismo_conn.stubs(:find_row).returns(row)
      user = User.find(1)
      user.should_not be_nil
      user.should be_an_instance_of(User)
      user.username.should == "blat"
    end
    
    it "should return nil if the user doesn't exist" do
      $mapismo_conn.stubs(:find_row).returns(nil)
      User.find(1).should be_nil
    end
  end
  
  describe "#maps" do
    it "should return an array of the maps of the user" do
      body = {
        "total_rows" => 2,
        "rows" => [
          {
            "cartodb_id" => 1,
            "name" => "15M in Madrid"
          },
          {
            "cartodb_id" => 2,
            "name" => "Gran Vía"
          }
        ]
      }
      
      response = mock()
      response.stubs(:code).returns("200")
      response.stubs(:body).returns(body.to_json)
      
      connection = mock()
      connection.expects(:run_query).once
      connection.stubs(:response).returns(response)
      
      User.any_instance.stubs(:connection).returns(connection)
      
      maps = subject.maps
      maps.size.should == 2
      
      maps[0].id.should == 1
      maps[0].name.should == "15M in Madrid"

      maps[1].id.should == 2
      maps[1].name.should == "Gran Vía"
    end
  end
  
  describe '.create' do
    let(:attributes) do
      {
        id: 1,
        username: 'blat',
        token: 'token',
        secret: 'secret'
      }
    end
    
    let(:connection) do
      connection = mock()
      connection.stubs(:create_table).returns(true)
      connection
    end
    
    before do
      User.any_instance.stubs(:connection).returns(connection)
    end
    
    it "should insert a new row on users table" do
      attrs_converted = {
        cartodb_user_id: attributes[:id],
        cartodb_username: attributes[:username],
        oauth_token: attributes[:token],
        oauth_secret: attributes[:secret]
      }
      $mapismo_conn.expects(:insert_row).with(Mapismo.users_table, attrs_converted).returns(true)
      User.create(attributes)
    end
    
    it "should setup the tables for the new user" do
      $mapismo_conn.stubs(:insert_row).returns(true)
      User.any_instance.expects(:setup_cartodb_tables!).once
      User.create(attributes)
    end
    
    it "should return a new user object" do
      $mapismo_conn.stubs(:insert_row).returns(true)
      user = User.create(attributes)
      user.should be_an_instance_of(User)
      user.username.should == "blat"
    end
  end
end