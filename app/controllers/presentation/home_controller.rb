class Presentation::HomeController < Presentation::AccessController
  def index
    # See if we need to redirect index on a custom domain
    domain = current_site.domains.where(host: request.host).first

    if domain.present? and domain.path.present?
      redirect_to domain.path
    else
      # Passing nil to channel_id will only return programs not assigned to a channel, we want everything
      @programs = pager(Program.where(status: :published).elem_match(allocations: { site_id: current_site.id }).order_by([:publish_at,:desc]).includes(:site),24)       
    
      render_rabl
    end
  end
end
