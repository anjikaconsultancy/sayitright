class System::UsersController < System::AccessController

  def index
    @users = current_site.users.order_by([:updated_at,:desc]).page(params[:page]).per(50)
  end

  def edit
    sign_out(:user)
    sign_in_and_redirect(:user, current_site.users.find(params[:id]))
  end

end