# coding: UTF-8

class SessionsController < ApplicationController
  def new
  end

  def create
    auth = request.env['omniauth.auth']
    session[:username] = auth.info.username
    session[:user_id] = auth.info.uid
    session[:token] = auth.extra.access_token.token
    session[:secret] = auth.extra.access_token.secret
    unless user = User.find(session[:user_id])
      user = User.create({
        id: session[:user_id], username: session[:username],
        token: session[:token], secret: session[:secret]
      })
    end
    session[:data_table_id] = user.data_table_id
    @current_user = setup_current_user

    if current_user.maps.empty?
      redirect_to new_map_path and return
    else
      redirect_to maps_path and return
    end
  end

  def failure
  end

  def destroy
    reset_session
    redirect_to root_path and return
  end
end
