# coding: UTF-8

class SiteController < ApplicationController
  def home
    if logged_in?
      redirect_to maps_path and return
    end
  end
end
