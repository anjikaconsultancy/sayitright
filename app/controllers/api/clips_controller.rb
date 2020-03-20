class Api::ClipsController < Api::AccessController
  def help
    #respond to the OPTIONS method with documentation?
  end
  
  def index
    if current_user.role != :user
      @clips = Clip.where(user: current_user.id)
    
      respond_with(@clips)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end  
  end
  
  def create 
    raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized") unless current_user.role != :user
    raise ActiveResource::BadRequest.new(t "errors.bad_request","Source URL is missing") unless params[:source].present?

    # Create a new clip to generate our S3 destination ID
    @clip = Clip.new
    @clip.user = current_user
    @clip.site = current_site
    @clip.source = params[:source]
    
    # Save will validate the source and trigger delayed job, raises an error if validation fails
    @clip.save!

    respond_with(@clip)
        
  end
end