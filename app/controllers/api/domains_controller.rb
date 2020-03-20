class Api::DomainsController < Api::AccessController
  # return a list of themes available to this user
  def index
    if [:administrator,:manager].include? current_user.role
      @domains = current_site.domains.all

      respond_with(@domains)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end     
  end

  def show
    if [:administrator,:manager].include? current_user.role
      @domain = current_site.domains.find(params[:id])      

      respond_with(@domain)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end    
  end

  def new
    if [:administrator,:manager].include? current_user.role
      @domain = current_site.domains.new

      respond_with(@domain)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end     
  end
  
  def create
    if [:administrator,:manager].include? current_user.role
      @domain = current_site.domains.new
      @domain.assign_attributes(resource_params)
      @domain.save  
            
      respond_with(@domain)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end     
  end

  def update  
    if [:administrator,:manager].include? current_user.role
      @domain = current_site.domains.find(params[:id])      
      @domain.update_attributes(resource_params)  
      respond_with(@domain)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end 
  end

  def destroy
    if [:administrator,:manager].include? current_user.role
      @domain = current_site.domains.find(params[:id])      
      @domain.destroy  
      respond_with(@domain)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end   
  end

  def resource_params
    permits = [:host,:path]
    params.permit(*permits)    
  end
  
  
end