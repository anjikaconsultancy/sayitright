module Dashboard::RegistrationsHelper
  #make devise errors look like ours
  def registration_error_messages!(msg)
    return "" if resource.errors.empty?
    content_tag(:div, msg, :class => [:flash,"flash_devise"])  
  end
end