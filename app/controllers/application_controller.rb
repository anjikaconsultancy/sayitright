class ApplicationController < ActionController::Base
  
  helper_method :current_site
  # rescue_from Exception, :with=> :exception
  before_action :mailer_set_url_options

  protect_from_forgery with: :exception
  
  # before_action do
  #   # Parameters for debugging
  #   ::NewRelic::Agent.add_custom_parameters(host: current_site.host) if current_site.present?
  #   ::NewRelic::Agent.add_custom_parameters(site: current_site.id.to_s) if current_site.present?
  #   ::NewRelic::Agent.add_custom_parameters(user: current_user.id.to_s) if current_user.present?
  # end

  def exception(exception)
    puts exception.inspect
    case exception
    when ActionController::RoutingError, Mongoid::Errors::DocumentNotFound#, Moped::Errors::InvalidObjectId
      @error = {status: 404,title: "Not Found", message: "There is nothing here."}
    when ActiveResource::UnauthorizedAccess
      @error = {status: 401,title: "Unauthorized", message: "You do not have access to this URL."}
    else
      @error = {status: 500,title: "Internal Server Error", message: "An unknown error occurred."}
    end
    
    respond_to do |format|
      format.html { render layout: "error", text: "",status:@error[:status]}
      format.json { render json: @error,status:@error[:status]}
      format.xml { render xml: @error, root: "error",status:@error[:status]}
      format.all  { render nothing: true, status:@error[:status] }
    end    
  end

  def current_site
    if params[:site_host].present?
      # Switch site
      @current_site = nil
      session[:site_host] = params[:site_host]
    end
        
    if defined? @current_site and @current_site.present?
      @current_site
    else
      if session[:site_host].present?
        # Grab the site from a session id
        @current_site = Site.find_by(host: session[:site_host])
      else  
        # Count parts so we can detect subdomain on either .com .co.uk etc.
        parts = ENV['DEFAULT_HOST'].count "."
        sub_domain = request.subdomain(parts)
        sub_domain = 'localhost'
        if request.domain(parts) == ENV['DEFAULT_HOST'] and sub_domain != "www"
          # @current_site = Site.find_by(host: request.subdomain(parts))
          @current_site =  Site.find_by(host: "localhost")
        else
          #Site.elem_match(domains: { host: domain.host})  
          @current_site = Site.find_by(:domains.elem_match => { host: request.host })
        end  

      end
    end
  end

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
      
end
