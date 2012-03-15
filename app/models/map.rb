# coding: UTF-8

class Map
  VALID_SOURCES = %W{ instagram flickr }
  
  attr_reader :user_id, :keywords, :sources, :radius, 
              :end_date, :start_date, :lat, :lon
  
  attr_accessor :name, :location_name, :id
  
  def initialize(attributes = {})
    @id = attributes[:id] || nil
    @name = attributes[:name] || ""
    @location_name = attributes[:location_name] || ""
    
    if attributes[:user_id]
      @user_id = attributes[:user_id].to_i
    else
      raise "User is required"
    end
    
    self.keywords   = attributes[:keywords]
    self.sources    = attributes[:sources]
    self.radius     = attributes[:radius]
    self.lat        = attributes[:lat]
    self.lon        = attributes[:lon]
    self.start_date = attributes[:start_date]
    self.end_date   = attributes[:end_date]
  end
  
  def keywords=(value)
    value ||= []
    if value.is_a?(String)
      value = value.split(',').map{ |k| k.strip }.compact.flatten
    end
    if value.size > 10
      raise "Only 10 keywords are allowed"
    end
    @keywords = value
  end
  
  def sources=(value)
    value ||= []
    if value.is_a?(String)
      value = value.split(',').map{ |k| k.strip }.compact.flatten
    end
    value.delete_if{ |v| v.blank? }
    value.each do |source|
      raise "Source #{source} is not allowed" unless VALID_SOURCES.include?(source)
    end
    @sources = value
  end
  
  def radius=(value)
    value ||= 1_000
    value = value.to_i
    raise "Radius must be a possitive value" if value < 0
    raise "Radius must be a value between 0 and 5000" if value > 5_000
    @radius = value
  end
  
  def start_date=(value)
    @start_date = validate_date(value)
  end
  
  def end_date=(value)
    @end_date = validate_date(value)
  end
  
  def lat=(value)
    @lat = value.nil? ? 0.0 : value.to_f
  end

  def lon=(value)
    @lon = value.nil? ? 0.0 : value.to_f
  end
  
  def user
    User.find(@user_id)
  end
  
  # find a map
  # requires :id and :user_id in the attributes
  def self.find(attributes)
    attributes.symbolize_keys!
    
    raise "Map ID is required" if attributes[:id].blank?
    map_id = attributes[:id].to_i
    
    raise "User ID or User is required" if attributes[:user_id].blank? && attributes[:user].blank?
    user = attributes[:user_id] ? User.find(attributes[:user_id]) : attributes[:user]
    
    connection = user.get_connection
    
    if row = connection.find_row(Mapismo.maps_table, "cartodb_id = #{map_id}")
      new(row_to_attributes(row, user))
    else
      nil
    end
  end
  
  def save
    row = {
      name: @name,
      sources: self.sources.join(','),
      keywords: self.keywords.join(','),
      start_date: self.start_date,
      end_date: self.end_date,
      radius: self.radius,
      location_name: self.location_name,
      lat: self.lat,
      lon: self.lon
    }
    
    connection = self.user.get_connection
    if connection.insert_row(Mapismo.maps_table, row)
      @id = connection.get_id_from_last_record(Mapismo.maps_table)
      notify_workers
      return true
    else
      raise "Error creating map: #{$!}"
    end
  end
  
  def self.row_to_attributes(row, user)
    {
      id: row["cartodb_id"].to_i,
      name: row["name"],
      user_id: user.id,
      sources: row["sources"],
      keywords: row["keywords"],
      start_date: row["start_date"],
      end_date: row["end_date"],
      radius: row["radius"],
      location_name: row["location_name"],
      lat: row["lat"],
      lon: row["lon"]
    }
  end
  
  private
  
  def validate_date(value)
    value = value.to_s
    unless value.blank?
      raise "Invalid format" if value !~ /\d{4}-\d{1,2}-\d{1,2}\+\d{1,2}:\d{1,2}:\d{1,2}/
      begin
        Time.parse(value)
      rescue
        raise "Invalid date"
      end
    end
    value
  end
  
  def notify_workers
    user = self.user
    base_message = {
      cartodb_table_name: Mapismo.data_table,
      cartodb_map_id: self.id,
      cartodb_username: user.username,
      cartodb_userid: self.user_id,
      cartodb_auth_token: user.token, 
      cartodb_auth_secret: user.secret,
      latitude: self.lat,
      longitude: self.lon,
      radius: self.radius,
      start_date: self.start_date,
      end_date: self.end_date
    }
    worker_notifier = WorkerNotifier.new
    
    self.keywords.each do |k|
      self.sources.each do |s|
        worker_notifier.notify!(base_message.merge(keyword: k, source: s))
      end
    end
  end
  
end