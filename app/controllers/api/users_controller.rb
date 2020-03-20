class Api::UsersController < Api::AccessController
  def help
    #respond to the OPTIONS method with documentation?
  end
  
  def index
    if [:administrator,:manager].include?(current_user.role)
      respond_with(@users = current_site.users)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end  
  end
  
  def show
    if params[:id]
      if [:administrator,:manager].include?(current_user.role)
        respond_with(@user = current_site.users.find(params[:id]))
      else
        raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
      end
    else
      respond_with(@user = current_user)
    end
  end
  
  def update  
  
    if params[:id] and params[:id] != current_user.id.to_s # json includes id on current_user so allow for that
      if [:administrator,:manager].include?(current_user.role)
        @user = current_site.users.find(params[:id])
      else
        raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")     
      end
    else
      @user = current_user
    end 
    
    @user.update_attributes(resource_params)
            
    respond_with(@user) 
  end
  
  
  private
  
  def resource_params
    permits = [:email, :bio, :website, :language, :time_zone, :password,:password_confirmation, 
               :name, :username,:accept_terms,:accept_marketing_from_partners,:accept_marketing,
                :header_source,:avatar_source]

    if current_user.role == :administrator
      permits.concat [:role, :status]
    # ERROR - secure_params is not working - does not exist?
    #elsif current_user.role == :manager and secure_params[:role].to_sym != :administrator
    elsif current_user.role == :manager and params[:role] != "administrator"
      # Allow manager to set any roles except administrator
      permits.concat [:role]
    end
    
    params.permit(*permits) 
  end  
end
