class Presentation::ChannelsController < Presentation::AccessController
  
  def index
    @channels = pager(current_site.channels.where(status: :published).order_by([:publish_at,:desc]),24)       

    render_rabl  
  end
    
  def show
    @channel = current_site.channels.find_from_path(params[:id])   
    @programs = Program.where(status: :published)
    @programs = @programs.elem_match(allocations: { site_id: current_site.id, channel_id: @channel.try(:id) })

    unless @channel
      @programs = @programs.where(site_id: current_site.id)
    end
    
    # unless @channel.public
    #   @programs = @programs.where(site_id: current_site.id)
    # end
    @programs = @programs.all_in(tags: params[:tagged].split(",")) if params[:tagged].present? 
    @programs = @programs.or({title: /#{params[:search]}/i}, {summary: /#{params[:search]}/i} ) if params[:search].present?
    @programs = @programs.where(title: /#{params[:title]}/i) if params[:title].present?
    @programs = @programs.where(summary: /#{params[:summary]}/i) if params[:summary].present?

    @programs = @programs.order_by([:publish_at,:desc]).includes(:site)
    @programs = pager(@programs,24)           
    
    #render_rabl
    
    if request.format.rss?
      respond_to do |format|
        format.rss { render :layout => false }
      end
    else
      render_rabl
    end  
  end
end
