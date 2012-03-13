# coding: UTF-8

require 'spec_helper'

describe SessionsController do
  describe "POST #create" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        'info' => {
          'username' => 'blat',
          'uid' => 1
        },
        'extra' => {
          'access_token' => {
            'token' => 'token',
            'secret' => 'secret'
          }
        }
      )
    end
    
    it "should set as the current_user the user found in the authentication process" do
      request.env['omniauth.auth'] = auth
      
      user = mock()
      user.stubs(:maps).returns([])
      User.expects(:find).with(1).returns(user).times(2)
      
      post :create
      subject.current_user.should == user
      response.should be_redirect
    end
    
    it "should set as the current_user from a user created" do
      request.env['omniauth.auth'] = auth
      
      user = mock()
      user.stubs(:maps).returns([])
      User.expects(:find).with(1).times(2).returns(nil).then.returns(user)
      User.expects(:create).with({
        id: 1, username: 'blat', 
        token: 'token', secret: 'secret'
      }).returns(user)
      
      post :create
      subject.current_user.should == user
      response.should be_redirect
    end
  end
end