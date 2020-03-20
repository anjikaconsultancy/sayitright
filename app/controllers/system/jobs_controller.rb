class System::JobsController < System::AccessController

  def index
  end

  def show
    case params[:id]
    when "update_programs"
      Delayed::Job.enqueue(UpdateProgramsJob.new)
    when "update_sites"
      Delayed::Job.enqueue(UpdateSitesJob.new)
    when "update_clips"
      Delayed::Job.enqueue(UpdateClipsJob.new(params[:status]))
    when "retry_clips"
      Delayed::Job.enqueue(RetryClipsJob.new(params[:status]))
    when "fix_clips"
      Delayed::Job.enqueue(FixClipsJob.new(params[:status]))
    end    
    redirect_to system_jobs_path
  end

end