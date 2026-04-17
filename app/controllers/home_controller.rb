class HomeController < ApplicationController
  layout "landing"

  def index
    redirect_to decks_path if user_signed_in?
  end
end
