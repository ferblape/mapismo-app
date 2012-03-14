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
      User.expects(:find).with(1).returns(user).once
      
      post :create
      response.should be_redirect

      current_user = subject.current_user
      current_user.should be_an_instance_of(User)
      current_user.username.should == 'blat'
      current_user.id.should == 1
    end
    
    it "should set as the current_user from a user created" do
      request.env['omniauth.auth'] = auth
      
      user = mock()
      user.stubs(:maps).returns([])
      User.expects(:find).with(1).times(1).returns(nil)
      User.expects(:create).with({
        id: 1, username: 'blat', 
        token: 'token', secret: 'secret'
      }).returns(user)
      
      post :create
      response.should be_redirect
      
      current_user = subject.current_user
      current_user.should be_an_instance_of(User)
      current_user.username.should == 'blat'
      current_user.id.should == 1
    end
  end
end