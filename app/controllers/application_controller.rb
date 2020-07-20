class ApplicationController < ActionController::Base
  include Presentation::AccessHelper

  # rescue_from Exception, :with=> :exception
  before_action :mailer_set_url_options
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  before_action do
    # Parameters for debugging
    ::NewRelic::Agent.add_custom_attributes(host: current_site.host) if current_site.present?
    ::NewRelic::Agent.add_custom_attributes(site: current_site.id.to_s) if current_site.present?
    ::NewRelic::Agent.add_custom_attributes(user: current_user.id.to_s) if current_user.present?
  end

  def exception(exception)
    puts exception.inspect
    case exception
    when ActionController::RoutingError, Mongoid::Errors::DocumentNotFound
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

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
      
end
