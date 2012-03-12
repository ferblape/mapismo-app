# coding: UTF-8

require 'spec_helper'

describe "MapismoApp::AdminCartoDBConnection" do
  it "should use Mapismo tokens to get initialized" do
    consumer = mock()
    MapismoApp::AdminCartoDBConnection.any_instance.expects(:load_consumer).returns(consumer)
    
    OAuth::AccessToken.expects(:new).with(consumer, Mapismo.oauth_token, Mapismo.oauth_secret).returns(mock())
    c = MapismoApp::AdminCartoDBConnection.new
    c.should_not be_nil
  end
end