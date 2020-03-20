class Api::SitesController < Api::AccessController
  def help
    #respond to the OPTIONS method with documentation?
  end
    
  def show
    respond_with(@site = current_site)
  end
  
  def update  
    #puts resource_params
    #raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")         
    #return
    
    if [:administrator,:manager].include?(current_user.role)
    
      @site = current_site
      @site.update_attributes(resource_params)
        
      respond_with(@site) 
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")         
    end
  end
    
  private
  
  def resource_params
    permits = [ :title,:host,:summary,:copyright,:registerable,:theme_id,
                :home_url,:about_url,:terms_url,:privacy_url,:contact_url,:help_url,:banner_url,:contact_email,
                :logo_source,:icon_source,:background_source,:banner_source,:header_source,
                :facebook_page_id,:twitter_id,:google_page_id,
                :google_analytics_id,:message,:warning]
    permits << {domains_attributes: [:id,:host,:path,:_destroy]}

    
    # Fix the theme id - note we use has_key not try as we want to set nil to remove a theme
    params[:theme_id] = params[:theme][:id] if params.has_key?(:theme) and params[:theme].has_key?(:id)

    params[:domains_attributes] = params[:domains] if params[:domains].present?

    
      

    params.permit(*permits) 
  end  
end
