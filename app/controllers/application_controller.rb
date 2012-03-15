# coding: UTF-8

class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  def current_user
    if session[:user_id]
      @current_user ||= User.new({id: session[:user_id], username: session[:username],
                                  token: session[:token], secret: session[:secret],
                                  data_table_id: session[:data_table_id]})
    end
    @current_user
  end

  def logged_in?
    !!current_user
  end
  
  def render_404
    render file: "public/404.html", status: 404, layout: false
  end
  
  protected
  
  def login_required
    return true if logged_in?
    redirect_to login_path and return false
  end
end
