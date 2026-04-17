class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_locale

  def after_sign_in_path_for(_resource)
    decks_path
  end

  private

  def set_locale
    requested = session[:locale] || I18n.default_locale.to_s
    I18n.locale = I18n.available_locales.map(&:to_s).include?(requested) ? requested : I18n.default_locale
  end
end
