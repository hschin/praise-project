class ThemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deck

  def create
    attrs = theme_params.to_h
    attrs[:name] = "Custom" if attrs[:name].blank?
    remove_image = attrs.delete("remove_background_image") == "1"

    @theme = @deck.theme || Theme.new
    @theme.background_image.purge if remove_image && @theme.background_image.attached?
    @theme.assign_attributes(attrs)
    @theme.source ||= "custom"

    if @theme.save
      @deck.update_column(:theme_id, @theme.id)
      redirect_to @deck, notice: "Theme applied."
    else
      redirect_to @deck, alert: "Could not apply theme: #{@theme.errors.full_messages.to_sentence}"
    end
  end

  def suggest
    GenerateThemeSuggestionsJob.perform_later(@deck.id)
    redirect_to @deck, notice: "Generating theme suggestions..."
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:deck_id])
  end

  def theme_params
    params.require(:theme).permit(:name, :source, :background_color, :text_color, :font_size, :background_image, :unsplash_url, :remove_background_image)
  end
end
