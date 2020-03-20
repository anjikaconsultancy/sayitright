class Setup::SitesController < ApplicationController
  layout "security"

  respond_to :html

  def new
    @site = Site.new
    @site.users << User.new
    
    respond_with @site
  end

  def create
    @site = Site.new
    @site.assign_attributes(resource_params)
    @user = @site.users.first
    @user.role = :administrator
    @user.accept_terms = true
    @site.billing_email = @user.email
    @site.billing_contact = @user.name

    @site.save

    # If this is successfull we redirect to the new site
    respond_with(@site,location: root_url(host: @site.default_host))
    
  end
  
  
  def resource_params
    permits = [:host,:title,{users_attributes: [:name,:email,:password]}]
    params.require(:site).permit(*permits)
  end
end
