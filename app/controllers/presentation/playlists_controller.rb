class Presentation::PlaylistsController < ApplicationController

  respond_to :html
      
  def show
    @program = Program.find_from_path(params[:program_id],current_site)
    
    respond_with(@program)
  end
end