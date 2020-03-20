class System::SitesController < System::AccessController

  def index
    @sites = Site.order_by([:created_at,:desc]).page(params[:page]).per(50)
  end

  def show
    @site = Site.find(params[:id])  
    redirect_to root_path(:host=>@site.default_host)
  end

  def edit
    @site = Site.find(params[:id])  
    @networks = Site.where(is_network: true)
  end

  def update
    @site = Site.find(params[:id])
    @site.update_attributes(resource_params)
        
    redirect_to system_sites_path
  end

  def resource_params
    permits = [:title, :is_network,:is_contributor,:network_id,:status]
    
    #params[:network_id] = params[:network][:id] if params.has_key?(:network) and params[:network].has_key?(:id)


    params[:site].permit(*permits) 
  end  


  
end
