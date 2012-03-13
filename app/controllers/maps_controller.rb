# coding: UTF-8

class MapsController < ApplicationController
  
  before_filter :login_required
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
      redirect_to edit_map_path(@map.id), flash: {notice: "Your map has been created successfully"}
    else
      render "new"
    end
  end

  def edit
  end

  def delete
  end

  protected 
  
  def load_map
    @map = Map.find(user_id: current_user.id, id: params[:id])
  end
  
end
