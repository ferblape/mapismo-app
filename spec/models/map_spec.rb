# coding: UTF-8

require 'spec_helper'

describe Map do
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
        sources: ["twitter", "flickr"],
        radius: 3500,
        location_name: "Madrid",
        location: nil,
        start_date: "2011-05-15+00:00:00",
        end_date: "2011-05-15+23:59:59"
      })
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
      subject.sources.should == ["twitter", "flickr"]
    end
  
    it "has a radius" do
      subject.radius.should == 3500
    end
  
    it "has a location name" do
      subject.location_name.should == "Madrid"
    end

    it "has a location point" do
      subject.location.should be_nil
    end
  
    it "has a start date" do
      subject.start_date.should == "2011-05-15+00:00:00"
    end
  
    it "has an end date" do
      subject.end_date.should == "2011-05-15+23:59:59"
    end
  end
end