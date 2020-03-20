class Api::ChannelsController < Api::AccessController
  def help
    #respond to the OPTIONS method with documentation?
  end
  
  def index
    if [:administrator,:manager].include?(current_user.role)
      @channels = current_site.channels

      respond_with(@channels)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end  
  end
  
  def new
  
    if [:administrator,:manager].include?(current_user.role) 
      @channel = Channel.new
      @channel.title = "New Channel"
            
      respond_with(@channel)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end    
  end
  
  def create
    if [:administrator,:manager].include?(current_user.role) 
      @channel = Channel.new
      @channel.title = "New Channel"
      @channel.site = current_site
      @channel.assign_attributes(resource_params)
      @channel.save      

      respond_with(@channel)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end    
      
  end

  def show
    if [:administrator,:manager].include?(current_user.role) 
      @channel = current_site.channels.find(params[:id])

      respond_with(@channel)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end    
  end
  
  def update  
    if [:administrator,:manager].include?(current_user.role) 
      @channel = current_site.channels.find(params[:id])
      @channel.update_attributes(resource_params)  
      respond_with(@channel)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end 
  end


  def resource_params
    # This should look like this but rails is not copying all the params into the channel params without setting everything in attr_accessible also.
    #if params[:channel].present?
    #  params[:channel][:station_id] = params[:channel][:station][:id] if params[:channel].try(:[],:station).try(:[],:id).present?
    #end
    #params.require(:channel).permit(*permits)

    params[:station_id] = params[:station][:id] if params.try(:[],:station).try(:[],:id).present?  
    permits = [:name,:title,:summary,:content,:tags,:status,:public,:featured,:station_id,:publish_at,:preview_source]
    params.permit(*permits)
  end
end
