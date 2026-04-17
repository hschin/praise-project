class LocalesController < ApplicationController
  def update
    locale = params[:locale].to_s
    locale = I18n.default_locale.to_s unless I18n.available_locales.map(&:to_s).include?(locale)
    session[:locale] = locale
    redirect_back(fallback_location: root_path)
  end
end
