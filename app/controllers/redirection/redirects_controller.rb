class Redirection::RedirectsController < ApplicationController
  def show
    redirect_to root_path
  end
end
