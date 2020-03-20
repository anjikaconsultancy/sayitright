class Presentation::StationsController < Presentation::AccessController
      
  def index
    @stations = current_site.stations.where(status: :live)

    @stations = @stations.order_by([:created_at,:desc])
    @stations = pager(@stations,24) 
    
    render_rabl  
  end
end