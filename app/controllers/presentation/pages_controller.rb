class Presentation::PagesController < Presentation::AccessController
      
  def show
    @page = current_site.pages.find_from_path(params[:id])
    render_rabl  
  end
end
