module ApplicationHelper


  # error to bootstrap level
  def flash_class(level)
    case level
      when :notice then 'info'
      when :error then 'error'
      when :alert then 'warning'
    end
  end

  # status flag to bootstrap level, we mix site, user and things status so convert them all
  def status_class(status)
    case status
      #site
      when :live then 'success'
      when :suspended then 'error'

      #posts
      when :draft then 'default'
      when :listed then 'success'
      when :published then 'info'

      #user
      when :active then 'success'
      
      else 'default'
    end
  end
  
  def active_nav(active_path)
    return "active" if request.fullpath == active_path
  end
  
  
  # clean the html
  def clean(html,config = {})
    Sanitize.clean(html,config)  
  end
  
  # stars out part of a string
  def star(text)
    return text if text.nil?
    text[0...text.length/3] + ("*" * (text.length/3)*2)
  end
  
  # the current controller namespace
  def controller_namespace
    controller.class.name.split("::").first.downcase 
  end
  
  def errors_for(object,method=nil)
    #instance_variable_get("@#{object}")
    if method
      e = object.errors[method]
    else
      e = object.errors.full_messages
    end
    
    return content_tag :span, e.to_sentence.capitalize,:class=>:errors_for if e
  end
  
  def button_tag(label,opt={:type=>:submit})
    content_tag(:button,  label, opt)
  end

  
end
