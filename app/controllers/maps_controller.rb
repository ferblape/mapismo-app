# coding: UTF-8

class MapsController < ApplicationController
  
  before_filter :login_required, except: [:show]
  before_filter :load_map, only: [:edit, :delete]

  def index
    @maps = current_user.maps
  end

  def new
    @map = Map.new(user_id: current_user.id)
  end

  def create
    @map = Map.new(params[:map].merge(user_id: current_user.id))
    if @map.save
      redirect_to map_path(current_user.id, @map.id), flash: {notice: "Your map has been created successfully"}
    else
      render "new"
    end
  end

  def show
    unless user = User.find(params[:user_id])
      render_404 and return
    end
    unless @map = Map.find(user_id: user.id, id: params[:id])
      render_404 and return
    end
  end

  def delete
    @map = Map.find(user_id: current_user.id, id: params[:id])
  end
  
end
