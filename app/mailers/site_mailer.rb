class SiteMailer < ActionMailer::Base
  
  def contact_email(to,from,name,message)
    @name = name
    @message = message
    mail(:to => to, :from=>from, :subject => "Contact Form")
  end  
end
