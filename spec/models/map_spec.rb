# coding: UTF-8

require 'spec_helper'

describe Map do
  describe ".find" do
    context "when the map does not exists" do
      before do
        connection = mock()
        connection.stubs(:find_row).returns(nil).with(Mapismo.maps_table, "cartodb_id = 1")
        
        user = mock()
        user.stubs(:id).returns(1)
        user.stubs(:get_connection).returns(connection)
        User.stubs(:find).with(1).returns(user)
      end
      
      it "should return nil" do
        Map.find(id: 1, user_id: 1).should be_nil
      end
    end

    context "when the map exists" do
      before do
        row = {
          "cartodb_id" => "15",
          "name" => "15M in Madrid",
          "sources" => "instagram,flickr",
          "keywords" => "15m, indignados",
          "start_date" => "2011-12-03+13:45:00",
          "end_date" => "2011-12-03+14:45:00",
          "radius" => "2500",
          "location_name" => "Madrid"
        }
        connection = mock()
        connection.stubs(:find_row).returns(row).with(Mapismo.maps_table, "cartodb_id = 1")
        
        user = mock()
        user.stubs(:id).returns(1)
        user.stubs(:get_connection).returns(connection)
        User.stubs(:find).with(1).returns(user)
      end
      
      it "should return an instance of the map when using user_id" do
        map = Map.find(id: 1, user_id: 1)
        map.should be_an_instance_of(Map)
        map.name.should == "15M in Madrid"
        map.user_id.should == 1
        map.id.should == 15
        map.sources.should == %W{ instagram flickr }
        map.keywords.should == %W{ 15m indignados }
        map.start_date.should == "2011-12-03+13:45:00"
        map.end_date.should ==  "2011-12-03+14:45:00"
        map.radius.should == 2_500
      end

      it "should return an instance of the map when using user object" do
        map = Map.find(id: 1, user: User.find(1))
        map.should be_an_instance_of(Map)
        map.name.should == "15M in Madrid"
        map.user_id.should == 1
      end
    end
  end
  
  describe "save" do
    context "when the data is ok and the map is valid" do
      let(:subject) do 
        Map.new({
          name: "15M in Madrid",
          user_id: 1,
          keywords: ["15m", "indignados"],
          sources: ["instagram", "flickr"],
          radius: 3500,
          location_name: "Madrid",
          lat: 40.416691,
          lon: -3.700345,
          start_date: "2011-05-15+00:00:00",
          end_date: "2011-05-15+23:59:59"
        })
      end
      
      before do
        connection = mock()
        connection.expects(:insert_row).once.returns(true)
        connection.expects(:get_id_from_last_record).with(Mapismo.maps_table).once.returns(33)
        
        user = mock()
        user.stubs(:id).returns(1)
        user.stubs(:username).returns('blat')
        user.stubs(:token).returns('token')
        user.stubs(:secret).returns('secret')
        user.stubs(:get_connection).returns(connection)
        
        Map.any_instance.stubs(:id).returns(33)
        Map.any_instance.stubs(:user).returns(user)
      end
        
      it "should insert a new row" do
        subject.save.should == true
      end
      
      it "should assign id 33 to the new map" do
        subject.save
        subject.id.should == 33
      end
      
      it "should notify the workers" do
        base_message = {
          cartodb_table_name: Mapismo.data_table,
          cartodb_map_id: subject.id,
          cartodb_username: subject.user.username,
          cartodb_userid: subject.user_id,
          cartodb_auth_token: subject.user.token, 
          cartodb_auth_secret: subject.user.secret,
          latitude: subject.lat,
          longitude: subject.lon,
          radius: subject.radius,
          start_date: subject.start_date,
          end_date: subject.end_date
        }
        worker_notifier = mock()
        WorkerNotifier.expects(:new).once.returns(worker_notifier)
        
        worker_notifier.expects(:notify!).with({:cartodb_table_name => 'mapismo_data', :cartodb_map_id => 33, :cartodb_username => 'blat', :cartodb_userid => 1, :cartodb_auth_token => 'token', :cartodb_auth_secret => 'secret', :latitude => 40.416691, :longitude => -3.700345, :radius => 3500, :start_date => '2011-05-15+00:00:00', :end_date => '2011-05-15+23:59:59', :keyword => '15m', :source => 'instagram'})
        worker_notifier.expects(:notify!).with({:cartodb_table_name => 'mapismo_data', :cartodb_map_id => 33, :cartodb_username => 'blat', :cartodb_userid => 1, :cartodb_auth_token => 'token', :cartodb_auth_secret => 'secret', :latitude => 40.416691, :longitude => -3.700345, :radius => 3500, :start_date => '2011-05-15+00:00:00', :end_date => '2011-05-15+23:59:59', :keyword => '15m', :source => 'flickr'})
        worker_notifier.expects(:notify!).with({:cartodb_table_name => 'mapismo_data', :cartodb_map_id => 33, :cartodb_username => 'blat', :cartodb_userid => 1, :cartodb_auth_token => 'token', :cartodb_auth_secret => 'secret', :latitude => 40.416691, :longitude => -3.700345, :radius => 3500, :start_date => '2011-05-15+00:00:00', :end_date => '2011-05-15+23:59:59', :keyword => 'indignados', :source => 'instagram'})
        worker_notifier.expects(:notify!).with({:cartodb_table_name => 'mapismo_data', :cartodb_map_id => 33, :cartodb_username => 'blat', :cartodb_userid => 1, :cartodb_auth_token => 'token', :cartodb_auth_secret => 'secret', :latitude => 40.416691, :longitude => -3.700345, :radius => 3500, :start_date => '2011-05-15+00:00:00', :end_date => '2011-05-15+23:59:59', :keyword => 'indignados', :source => 'flickr'})
          
        subject.save
      end
    end

    context "when the data is wrong" do
      let(:subject) do 
        Map.new({
          name: "15M in Madrid",
          user_id: 1,
          keywords: ["15m", "indignados"],
          sources: ["instagram", "flickr"],
          radius: 3500,
          location_name: "Madrid",
          lat: 40.416691,
          lon: -3.700345,
          start_date: "2011-05-15+00:00:00",
          end_date: "2011-05-15+23:59:59"
        })
      end
      
      before do
        connection = mock()
        connection.expects(:insert_row).once.returns(false)
        
        user = mock()
        user.stubs(:id).returns(1)
        user.stubs(:get_connection).returns(connection)
        
        Map.any_instance.stubs(:user).returns(user)
      end
        
      it "should insert a new row" do
        lambda {
          subject.save
        }.should raise_error("Error creating map: ")
      end
    end
  end
  
  describe "#keywords= assignment" do
    let(:subject) { Map.new(user_id: 1) }
    
    it "should accept a string separated by commas" do
      subject.keywords = "kw1,kw2,  kw3"
      subject.keywords.should == %W{ kw1 kw2 kw3 }
    end

    it "should accept an array" do
      subject.keywords = ["k1","k2"]
      subject.keywords.should == %W{ k1 k2 }
    end

    it "should have a limit of 3 keywords" do
      lambda {
        subject.keywords = "k1,k2,k3,k4"
      }.should raise_error("Only 3 keywords are allowed")
    end
    
    it "should set an empty array by default" do
      subject.keywords = ""
      subject.keywords.should == []
    end

    it "should accept a word" do
      subject.keywords = "w1"
      subject.keywords.should == ["w1"]
    end
  end
  
  describe "#sources= assignment" do
    let(:subject) { Map.new(user_id: 1) }
    
    it "should only accept valid values" do
      lambda {
        subject.sources = %W{ instagram facebook }
      }.should raise_error("Source facebook is not allowed")
    end
    
    it "should accept a string separated by commas" do
      subject.sources = "flickr, instagram"
      subject.sources.should == %W{ flickr instagram }
    end

    it "should clear blank values from an array" do
      subject.sources = ["", "flickr","instagram", ""]
      subject.sources.should == %W{ flickr instagram }
    end

    it "should accept an array" do
      subject.sources = ["flickr","instagram"]
      subject.sources.should == %W{ flickr instagram }
    end

    it "should be an empty array by default" do
      subject.sources = nil
      subject.sources.should == []
    end
  end
  
  describe "#radius= assignment" do
    let(:subject) { Map.new(user_id: 1) }
    
    it "should only accept possitive values" do
      lambda {
        subject.radius = -1
      }.should raise_error("Radius must be a possitive value")
    end

    it "should only accept values between 0 and 5000" do
      lambda {
        subject.radius = 10_000
      }.should raise_error("Radius must be a value between 0 and 5000")
    end
    
    it "should set the raiuds as integer" do
      subject.radius = "33"
      subject.radius.should == 33
    end
    
    it "should be 1000 by default" do
      subject.radius = nil
      subject.radius.should == 1000
    end
  end
  
  describe "#start_date= assignment" do
    let(:subject) { Map.new(user_id: 1) }
    
    it "should only accepts strings in a valid format" do
      lambda {
        subject.start_date = "2011-01-01"
      }.should raise_error("Invalid format")
    end

    it "should only accepts valid dates" do
      lambda {
        subject.start_date = "2011-13-01+10:00:00"
      }.should raise_error("Invalid date")
    end

    it "should set a blank string by default" do
      subject.start_date = nil
      subject.start_date.should == ""
    end
    
    it "should set a valid date as string" do
      subject.start_date = "2011-12-01+23:50:00"
      subject.start_date.should == "2011-12-01+23:50:00"
    end
  end
  
  describe "#end_date= assignment" do
    let(:subject) { Map.new(user_id: 1) }
    
    it "should only accepts strings in a valid format" do
      lambda {
        subject.end_date = "2011-01-01"
      }.should raise_error("Invalid format")
    end

    it "should only accepts valid dates" do
      lambda {
        subject.end_date = "2011-13-01+10:00:00"
      }.should raise_error("Invalid date")
    end

    it "should set a blank string by default" do
      subject.end_date = nil
      subject.end_date.should == ""
    end

    it "should set a valid date as string" do
      subject.end_date = "2011-12-01+23:50:00"
      subject.end_date.should == "2011-12-01+23:50:00"
    end
  end
  
  context "an initialized map" do
    let(:user) do
      u = mock()
      u.stubs(:id).returns(1)
      u
    end
    
    let(:subject) do
      Map.new({
        name: "15M in Madrid",
        user_id: 1,
        keywords: ["15m", "indignados"],
        sources: ["instagram", "flickr"],
        radius: 3500,
        location_name: "Madrid",
        lat: 40.416691,
        lon: -3.700345,
        start_date: "2011-05-15+00:00:00",
        end_date: "2011-05-15+23:59:59"
      })
    end
    
    it "has a nil id" do
      subject.id.should == nil
      subject.id = 3
      subject.id.should == 3
    end
  
    it "has a name" do
      subject.name.should == "15M in Madrid"
    end
  
    it "belongs to an user" do
      User.stubs(:find).with(1).returns(user)
      subject.user_id.should == 1
      subject.user.should == user
    end
  
    it "has a list of keywords" do
      subject.keywords.should == ["15m", "indignados"]
    end
  
    it "has a list of sources" do
      subject.sources.should == ["instagram", "flickr"]
    end
  
    it "has a radius" do
      subject.radius.should == 3500
    end
  
    it "has a location name" do
      subject.location_name.should == "Madrid"
    end

    it "has a latitude" do
      subject.lat = "40.416691"
      subject.lat.should == 40.416691
    end
    
    it "has a longitude" do
      subject.lon = "-3.700345"
      subject.lon.should == -3.700345
    end
  
    it "has a start date" do
      subject.start_date.should == "2011-05-15+00:00:00"
    end
  
    it "has an end date" do
      subject.end_date.should == "2011-05-15+23:59:59"
    end
  end
end