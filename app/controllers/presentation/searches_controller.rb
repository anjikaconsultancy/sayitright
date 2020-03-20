class Presentation::SearchesController < Presentation::AccessController
  
  def show
    if params[:search].present? or params[:tagged].present? or params[:title].present? or params[:summary].present?
      @programs = Program.where(status: :published)
      @programs = @programs.elem_match(allocations: { site_id: current_site.id })
      @programs = @programs.all_in(tags: params[:tagged].split(",")) if params[:tagged].present? 
      @programs = @programs.or({title: /#{params[:search]}/i}, {summary: /#{params[:search]}/i} ) if params[:search].present?
      @programs = @programs.where(title: /#{params[:title]}/i) if params[:title].present?
      @programs = @programs.where(summary: /#{params[:summary]}/i) if params[:summary].present?

      @programs = @programs.order_by([:publish_at,:desc]).includes(:site)
      @programs = pager(@programs,24)           
    else
      # hack in empty results
      @programs = pager(Program.where(status: :empty),24)           
    end
    render_rabl  
  end
end
