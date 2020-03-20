class System::ClipsController < System::AccessController

  def index
    @clips = Clip.order_by([:created_at,:desc]).page(params[:page]).per(100)
  end

  def show
    @clip = Clip.find(params[:id])  
    if @clip and params[:status]
      @clip.status = params[:status].to_sym
      @clip.save
    end
    redirect_to system_clips_path
  end
  
end
