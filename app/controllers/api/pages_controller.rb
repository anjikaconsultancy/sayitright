class Api::PagesController < Api::AccessController
  # return a list of pages available to this user
  def index
    if [:administrator,:manager].include? current_user.role
      @pages = current_site.pages.all

      respond_with(@pages)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end     
  end

  def show
    if [:administrator,:manager].include? current_user.role
      @page = current_site.pages.find(params[:id])      

      respond_with(@page)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end    
  end

  def new
    if [:administrator,:manager].include? current_user.role
      @page = Page.new

      respond_with(@page)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end     
  end
  
  def create
    if [:administrator,:manager].include? current_user.role
      @page = Page.new
      @page.site = current_site
      @page.assign_attributes(resource_params)
      @page.save  
            
      respond_with(@page)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end     
  end

  def update   
    if [:administrator,:manager].include? current_user.role
      @page = current_site.pages.find(params[:id])      
      @page.update_attributes(resource_params)  
      respond_with(@page)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end 
  end


  def resource_params
    params[:station_id] = params[:station][:id] if params.try(:[],:station).try(:[],:id).present?  
    permits = [:name,:title,:summary,:status,:featured,:content,:station_id]
    params.permit(*permits)    
  end
  
  
end