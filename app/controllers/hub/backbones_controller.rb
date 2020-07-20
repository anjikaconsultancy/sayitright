# Map all hub requests to the backbone layout
class Hub::BackbonesController < ApplicationController
  before_action :authenticate_user!

  respond_to :html

  layout "hub"

  def show
    # Render informational text into the js template
    render text: DateTime.now, layout: true
  end

end
