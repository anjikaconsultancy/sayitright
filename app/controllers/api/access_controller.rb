class Api::AccessController < ApplicationController
  before_action :authenticate_user!     
     
  respond_to :json,:xml  
      
  # For future versioning? 
  #res.header("Content-Type", "application/vnd.sayitright.productions+json");
  #res.header("Content-Type", "application/json, profile='sayitright-json'");  

  # When we render Rabl inline it does not get all the helpers, so wrap cloudinary in our own
  #helper_method :cdn_image_path
  
  #def cdn_image_path(source,options)
  #  Cloudinary::Utils.cloudinary_url(source, options)
  #end  
 
end
