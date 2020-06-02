class Api::ProgramsController < Api::AccessController
  def help
    #respond to the OPTIONS method with documentation?
  end
  
  def index
    if current_user.role != :user
      # This is correct for when we can stop editing from other sites
      # @programs = Program.elem_match(allocations: { site_id: current_site.id })
      # @programs = current_site.programs.order_by([:publish_at,:desc]).page(params[:page]).per(10)
      @programs = current_site.programs.order("publish_at DESC").page(params[:page]).per(10)
      # @programs = pager(@programs,50)

      respond_with(@programs)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")
    end
  end

  def show
    @program = current_site.programs.find(params[:id])
    if [:administrator,:manager,:moderator].include?(current_user.role) or @program.user.id == current_user.id
      respond_with(@program)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")
    end
  end

  def new
    if current_user.role != :user
      @program = Program.new
      @program.site = current_site
      @program.user = current_user
      @program.title = "New Program"

      #setup some default allocations
      @program.allocations.build(site: current_site,status: :published)
      @program.allocations.build(site: current_site,user: current_user,status: :published)
      
      #setup an empty text fragment  
      @program.fragments.build(content: "Enter some text.")
      
      respond_with(@program)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")  
    end
  end

  def create
    if current_user.role != :user
      @program = Program.new
      @program.site = current_site
      @program.user = current_user
      # resource_params is using @program.site so we can't use it in new
      @program.assign_attributes(resource_params)
      @program.save

      respond_with(@program)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")
    end
  end

  def update
    @program = current_site.programs.find(params[:id])
    if [:administrator,:manager,:moderator].include?(current_user.role) or @program.user.id == current_user.id
      @program.update_attributes!(resource_params)

      respond_with(@program)
    else
      raise ActiveResource::UnauthorizedAccess.new(t "errors.unauthorized")
    end
  end

  private

  def resource_params
    # Copy attributes to required keys
    # - We would normally do this with a hash, but delete is messed up in params hash.
    # - params[:fragments_attributes] = params.delete(:fragments)
    # - Also, requires if present? or the whole params gets wiped.
    params[:segments_attributes] = params[:segments] if params[:segments].present?
    params[:fragments_attributes] = params[:fragments] if params[:fragments].present?
    params[:allocations_attributes] = params[:allocations] if params[:allocations].present?

    # Fix allocations format and remove any that dont match our permissions
    if params[:allocations_attributes]
      params[:allocations_attributes].delete_if do |allocation|
        # Copy allocation id's to accepts_many format
        allocation[:site_id]    = allocation[:site][:id]    if allocation.try(:[],:site).try(:[],:id).present?    
        allocation[:station_id] = allocation[:station][:id] if allocation.try(:[],:station).try(:[],:id).present?   
        allocation[:channel_id] = allocation[:channel][:id] if allocation.try(:[],:channel).try(:[],:id).present?    
        allocation[:user_id]    = allocation[:user][:id]    if allocation.try(:[],:user).try(:[],:id).present?

        # TODO - Remove this if its not allowed
        # if true == false
        #   true
        # else
        #   false
        # end
      end
    end

    # Fix fragments and segments embedded clips
    if params[:segments_attributes]
      params[:segments_attributes].each do |segment|
        segment[:clip_id]    = segment[:clip][:id]    if segment.try(:[],:clip).try(:[],:id).present?
      end
    end
    # if params[:fragments_attributes]
    #   params[:fragments_attributes].each do |fragment|
    #     fragment[:clip_id]    = fragment[:clip][:id]    if fragment.try(:[],:clip).try(:[],:id).present?
    #   end
    # end

    # List of what were going to permit
    permits = []

    # Administrators, Managers can edit content if its on there own site, and owners can edit content
    if (@program.site.id == current_site.id and [:administrator,:manager].include?(current_user.role)) or @program.user.id == current_user.id
      element_content = [:id,:kind,:position,:content,:url,:clip_id,:_destroy]
      
      permits.concat [:name,:title,:rel,:summary,:language,:status,:tags,:publish_at]
      permits << {segments_attributes: element_content}
      # permits << {fragments_attributes: element_content}
    end

    # First permit allocations access to moderators on any site or owners
    if [:administrator,:manager,:moderator].include?(current_user.role) or @program.user.id == current_user.id
      # TODO - make sure we can only delete the allocation if allowed
      permits << {allocations_attributes: [:id,:site_id,:channel_id,:status,:_destroy]}
    end

    # Splat in the permits parameters
    params.permit(*permits)

  end

end
