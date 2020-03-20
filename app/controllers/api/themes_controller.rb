class Api::ThemesController < Api::AccessController
  # return a list of themes available to this user
  def index
    if [:administrator,:manager].include? current_user.role
      @themes = current_site.themes.all

      respond_with(@themes)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end     
  end

  def show
    if [:administrator,:manager].include? current_user.role
      @theme = current_site.themes.find(params[:id])      

      respond_with(@theme)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end    
  end

  def new
    if [:administrator,:manager].include? current_user.role
      @theme = Theme.new

      respond_with(@theme)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end     
  end
  
  def create
    if [:administrator,:manager].include? current_user.role
      @theme = Theme.new
      @theme.site = current_site
      @theme.assign_attributes(resource_params)
      @theme.save  
            
      respond_with(@theme)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end     
  end

  def update  
    if [:administrator,:manager].include? current_user.role
      @theme = current_site.themes.find(params[:id])      
      @theme.update_attributes(resource_params)  
      respond_with(@theme)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end 
  end

  def resource_params
    permits = [:title,:description,:availability,:editable,:template,:options,:formats,:syntax]
    
    params.require(:theme).permit(*permits)
  end
  
  
end