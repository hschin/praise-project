class DeckSongsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deck

  def create
    @deck_song = @deck.deck_songs.new(song_id: params[:song_id], key: params[:key])
    @deck_song.position = @deck.deck_songs.count + 1
    @deck_song.arrangement = @deck_song.song.lyrics.order(:position).pluck(:id).map(&:to_i)
    if @deck_song.save
      redirect_to @deck, notice: "Song added to deck."
    else
      redirect_to @deck, alert: "Could not add song."
    end
  end

  def update
    @deck_song = @deck.deck_songs.find(params[:id])
    if @deck_song.update(deck_song_params)
      redirect_to @deck, notice: "Updated."
    else
      redirect_to @deck, alert: "Could not update."
    end
  end

  def reorder
    @deck_song = @deck.deck_songs.find(params[:id])
    new_position = params[:position].to_i
    @deck_song.update!(position: new_position)
    head :ok
  end

  def update_arrangement
    @deck_song = @deck.deck_songs.find(params[:id])
    new_arrangement = Array(params[:arrangement]).map(&:to_i)
    @deck_song.update!(arrangement: new_arrangement)
    if request.content_type&.include?("application/json")
      head :ok
    else
      redirect_to @deck
    end
  end

  def destroy
    @deck_song = @deck.deck_songs.find(params[:id])
    @deck_song.destroy
    redirect_to @deck, notice: "Song removed from deck."
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:deck_id])
  end

  def deck_song_params
    params.require(:deck_song).permit(:song_id, :key, arrangement: [])
  end
end
