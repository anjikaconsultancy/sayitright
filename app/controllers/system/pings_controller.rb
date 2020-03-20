class System::PingsController < ApplicationController

  respond_to :html,:json

  def index
    respond_with do |format|
      format.html { render text: "OK" }
    end
  end
end