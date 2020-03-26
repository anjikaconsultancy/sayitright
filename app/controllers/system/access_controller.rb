class System::AccessController < ApplicationController
  # Allow http login with as the system admin, and ensure we set a password.
  http_basic_authenticate_with :name => "sysadmin", :password => ENV['SYSADMIN'].presence || '123123'

  layout "system"

  respond_to :html,:json

end