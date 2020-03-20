class Api::SystemsController < Api::AccessController
  def help
    #respond to the OPTIONS method with documentation?
  end
    
  def show
    respond_with(@system = System.first_or_create)
  end

end