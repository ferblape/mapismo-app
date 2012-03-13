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
  
end
