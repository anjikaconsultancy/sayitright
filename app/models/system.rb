class System
  include Mongoid::Document
  field :message, type: String
  field :warning, type: String
  
  def version
    Sirn::Application::APP_VERSION
  end
  def name
    Sirn::Application::APP_NAME
  end  
end
