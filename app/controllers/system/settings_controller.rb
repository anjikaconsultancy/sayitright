class System::SettingsController < System::AccessController
  def show
    @system = System.first_or_create
  end

  def update
    @system = System.first_or_create
    @system.update_attributes(resource_params)
        
    redirect_to system_settings_path
  end

  def resource_params
    permits = [:warning, :message]
    
    params[:system].permit(*permits) 
  end 
  
end
