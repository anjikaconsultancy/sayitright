class System::ProgramsController < System::AccessController

  def index
    @programs = current_site.programs.order_by([:created_at,:desc]).page(params[:page]).per(50).includes(:user)
  end

  def edit
    sign_out(:user)

    @program = current_site.programs.find(params[:id])
    
    sign_in(:user, @program.user)  

    redirect_to edit_program_path(@program)
      
  end
  
end
