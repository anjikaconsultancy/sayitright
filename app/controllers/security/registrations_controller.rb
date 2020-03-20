class Security::RegistrationsController < Devise::RegistrationsController

  layout "security" #proc{ |controller| user_signed_in? ? "application" : "modal" }

  def new
    raise ActionController::RoutingError.new(t "errors.messages.registration_is_disabled") unless current_site.registerable
    super
  end
  def create
    raise ActionController::RoutingError.new(t "errors.messages.registration_is_disabled") unless current_site.registerable
    super
  end
  
  def resource_params
    # Inject the site id and permit access.
    params[:user][:site_id] = current_site.id.to_s
    params.require(:user).permit(:name,:email, :password, :password_confirmation,:site_id,:accept_marketing,:accept_marketing_from_partners,:accept_terms)
  end
  private :resource_params    
end

