class System::ConnectionsController < System::AccessController

  def index
    @connections = current_site.connections #.page(params[:page]).per(50)
    puts @connections.inspect
  end

  def new
    @connection = current_site.connections.new
  end

  def create
    begin
      site = Site.find_from_path(params[:connection][:site_id])
      if site
        current_site.connections.new(site_id: site.id,moderated: false)
        current_site.save
      end
    rescue
    end

    redirect_to system_connections_path
  end
  
  def show
    destroy
  end
  
  def destroy
    connection = current_site.connections.find(params[:id])
    if connection
      connection.destroy
      current_site.save
    end
    
    redirect_to system_connections_path      
  end
  
end