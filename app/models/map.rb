# coding: UTF-8

class Map
  attr_reader :user_id
  
  attr_accessor :name, :keywords, :sources, :radius, :start_date,
                :location_name, :location, :end_date
  
  def initialize(attributes = {})
    @name = attributes[:name] || ""
    if attributes[:user_id]
      @user_id = attributes[:user_id].to_i
    else
      raise "User is required"
    end
    @keywords = attributes[:keywords] || []
    @sources = attributes[:sources] || []
    @radius = attributes[:radius].to_i || 0
    @location_name = attributes[:location_name] || ""
    @location = nil
    @start_date = attributes[:start_date] || nil
    @end_date = attributes[:end_date] || nil
  end
  
  def user
    User.find(@user_id)
  end
  
end