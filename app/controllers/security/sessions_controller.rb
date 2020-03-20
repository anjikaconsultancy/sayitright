class Security::SessionsController < Devise::SessionsController  
  layout "security"


  def create
    if current_user
      cookies[:current_user_name] = current_user.name
      cookies[:current_user_path] = user_path(current_user.path)
    else
      cookies.delete :current_user_name
      cookies.delete :current_user_path
    end
    
    super        
  end
  
  def destroy
    cookies.delete :current_user_name
    cookies.delete :current_user_path  
    
    super
  end
end