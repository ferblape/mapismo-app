# coding: UTF-8

class MapsController < ApplicationController
  
  before_filter :login_required, except: :show
  
  def new
    @map = Map.new(user_id: current_user.id)
  end

  def index
    @maps = current_user.maps
  end

  def create
  end

  def update
  end

  def delete
  end

  def show
  end
end
