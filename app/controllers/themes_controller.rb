class ThemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deck

  def create
    @theme = @deck.build_theme(theme_params)
    @theme.source = "custom"
    if @theme.save
      @deck.update_column(:theme_id, @theme.id)
      redirect_to @deck, notice: "Theme applied."
    else
      redirect_to @deck, alert: "Could not apply theme: #{@theme.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:deck_id])
  end

  def theme_params
    params.require(:theme).permit(:name, :background_color, :text_color, :font_size, :background_image)
  end
end
