# Map all cms requests to the angualr layout
class Cms::AngularsController < ApplicationController
  before_action :authenticate_user! 
       
  respond_to :html
  
  layout "cms"
    
  def show
    # Render informational text into the js template
    render text: DateTime.now, layout: true
  end
      
end
