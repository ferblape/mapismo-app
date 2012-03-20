# coding: UTF-8

require 'spec_helper'

describe 'User' do

  let(:subject) do
    User.new({
      id: 1,
      username: 'blat',
      token: 'token',
      secret: 'secret',
      data_table_id: 3
    })
  end

  it "should have an attribute id" do
    subject.id.should == 1
  end

  it "should have an attribute username" do
    subject.username.should == 'blat'
  end

  it "should have an attribute token" do
    subject.token.should == 'token'
  end

  it "should have an attribute secret" do
    subject.secret.should == 'secret'
  end

  it "should have an attribute data_table_id" do
    subject.data_table_id.should == 3
  end

  describe '.find' do
    it "should return an instance of user with the values of the row if exists" do
      row = {
        "cartodb_user_id" => 1,
        "cartodb_username" => "blat",
        "oauth_token" => "token",
        "oauth_secret" => "secret",
        "data_table_id" => "3"
      }
      $mapismo_conn.stubs(:find_row).returns(row)
      user = User.find(1)
      user.should_not be_nil
      user.should be_an_instance_of(User)
      user.username.should == "blat"
      user.data_table_id.should == 3
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
      connection.stubs(:response).returns(response)

      cartodb_connection = mock()
      cartodb_connection.stubs(:connection).returns(connection)
      cartodb_connection.expects(:run_query).once
      User.any_instance.stubs(:connection).returns(cartodb_connection)

      maps = subject.maps
      maps.size.should == 2

      maps[0].id.should == 1
      maps[0].name.should == "15M in Madrid"

      maps[1].id.should == 2
      maps[1].name.should == "Gran Vía"
    end
  end

  describe "#update_data_table_id!" do
    it "should get the id of data table and update users table" do
      body = {
        "tables" => [
          {"id"=>429, "name"=>"mapismo_data", "privacy"=>"PUBLIC", "tags"=>""}
        ]
      }

      response = mock()
      response.stubs(:code).returns("200")
      response.stubs(:body).returns(body.to_json)

      connection = mock()
      connection.stubs(:response).returns(response)
      connection.expects(:get).once.with("/api/v1/tables")

      cartodb_connection = mock()
      cartodb_connection.stubs(:connection).returns(connection)
      User.any_instance.stubs(:connection).returns(cartodb_connection)

      mapismo_conn_response = mock()
      mapismo_conn_response.stubs(:code).returns("200")
      mapismo_conn = mock()
      mapismo_conn.stubs(:response).returns(mapismo_conn_response)
      $mapismo_conn.stubs(:connection).returns(mapismo_conn)
      $mapismo_conn.expects(:run_query).with('UPDATE application_users_test SET data_table_id = 429 WHERE cartodb_user_id = 1').once

      subject.update_data_table_id!
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
        oauth_secret: attributes[:secret],
        data_table_id: 0
      }
      $mapismo_conn.expects(:insert_row).with(Mapismo.users_table, attrs_converted).returns(true)
      User.any_instance.stubs(:update_data_table_id!).returns(true)
      User.any_instance.stubs(:setup_cartodb_tables!).returns(true)

      User.create(attributes)
    end

    it "should setup the tables for the new user" do
      $mapismo_conn.stubs(:insert_row).returns(true)
      User.any_instance.stubs(:update_data_table_id!).returns(true)

      User.any_instance.expects(:setup_cartodb_tables!).once
      User.create(attributes)
    end

    it "should return a new user object" do
      $mapismo_conn.stubs(:insert_row).returns(true)
      User.any_instance.stubs(:update_data_table_id!).returns(true)
      User.any_instance.stubs(:setup_cartodb_tables!).returns(true)
      user = User.create(attributes)
      user.should be_an_instance_of(User)
      user.username.should == "blat"
    end

    it "should update data_table_id value from the user" do
      $mapismo_conn.stubs(:insert_row).returns(true)
      User.any_instance.expects(:update_data_table_id!).once.returns(true)
      User.any_instance.stubs(:setup_cartodb_tables!).returns(true)
      user = User.create(attributes)
      user.should be_an_instance_of(User)
      user.username.should == "blat"
    end
  end
end