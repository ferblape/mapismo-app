# coding: UTF-8

class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    end
    @current_user
  end

  def logged_in?
    !!current_user
  end
  
  protected
  
  def login_required
    return true if logged_in?
    redirect_to login_path and return false
  end
end
