class Presentation::ElementsController < ApplicationController

  respond_to :html
      
  def show
    @program = Program.find_from_path(params[:program_id])

    @element = @program.segments.where(id: params[:id]).first || @program.fragments.where(id: params[:id]).first
        
    respond_with(@element)
  end
end