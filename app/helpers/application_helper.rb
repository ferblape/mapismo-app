# coding: UTF-8

module ApplicationHelper

  def flush_the_flash
    content_tag(:div, id: 'flash') do
      if flash[:alert] || flash[:notice]
        content_tag(:p, class: "#{flash[:notice] ? 'notice' : 'error'}") do
          flash[:notice] || flash[:alert]
        end
      end
    end
  end

  def title(page_title)
    content_for :title do
      page_title + " · Mapismo"
    end
  end

  def cartodb_table_link
    return "" if @user.nil?
    "https://#{@user.username}.cartodb.com/tables/#{Mapismo.data_table}/embed_map"
  end

  def generate_preview_token
    rand(36**6).to_s(36)
  end

end
