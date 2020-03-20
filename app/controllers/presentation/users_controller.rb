class Presentation::UsersController < Presentation::AccessController

  def index
    @users = pager(current_site.users.order_by([:created_at,:desc]),24)       
    render_rabl 
  end
    
  def show
    @user = current_site.users.find_from_path(params[:id])
    render_rabl
  end
  
end
