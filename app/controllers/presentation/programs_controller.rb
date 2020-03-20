class Presentation::ProgramsController < Presentation::AccessController
  #respond_to :html, :json, :xml, :rss
  def index
    @channel = current_site.channels.find_from_path(params[:channel_id]) if params[:channel_id].present?

    @programs = Program.where(status: :published)
    # Passing nil to channel_id will only return programs not assigned to a channel, we want everything
    if @channel.try(:id)
      @programs = @programs.elem_match(allocations: { site_id: current_site.id, channel_id: @channel.try(:id) })
    else
      @programs = @programs.elem_match(allocations: { site_id: current_site.id })      
    end
    @programs = @programs.all_in(tags: params[:tagged].split(",")) if params[:tagged].present? 
    @programs = @programs.or({title: /#{params[:search]}/i}, {summary: /#{params[:search]}/i} ) if params[:search].present?
    @programs = @programs.where(title: /#{params[:title]}/i) if params[:title].present?
    @programs = @programs.where(summary: /#{params[:summary]}/i) if params[:summary].present?

    @programs = @programs.order_by([:publish_at,:desc]).includes(:site)
    @programs = pager(@programs,24)           
    if request.format.rss?
      respond_to do |format|
        format.rss { render :layout => false }
      end
    else
      render_rabl
    end  
  end
    
  def show
    @channel = current_site.channels.find_from_path(params[:channel_id]) if params[:channel_id].present?
    @program = Program.find_from_path(params[:id],current_site)
    render_rabl 
  end
end
