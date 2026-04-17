class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @total_songs         = Song.where(import_status: "done").count
    @songs_attempted     = Song.where.not(import_status: "pending").count
    @import_success_rate = @songs_attempted > 0 ? (@total_songs.to_f / @songs_attempted * 100).round(1) : 0
    @total_decks         = Deck.count
    @total_users         = User.count
    @total_generated     = Export.generated.count
    @total_downloaded    = Export.downloaded.count

    @recent_songs = Song.where(import_status: "done").order(created_at: :desc).limit(8)
    @top_songs    = Song.joins(:deck_songs)
                        .group(Arel.sql("songs.id"), Arel.sql("songs.title"), Arel.sql("songs.artist"))
                        .order(Arel.sql("count(deck_songs.id) desc"))
                        .limit(8)
                        .pluck(Arel.sql("songs.title"), Arel.sql("songs.artist"), Arel.sql("count(deck_songs.id)"))

    @recent_decks = Deck.includes(:user, :exports).order(created_at: :desc).limit(10)
    @users        = User.includes(:decks).order(created_at: :desc)
  end

  def decks
    @decks = Deck.includes(:user, :exports, :deck_songs).order(created_at: :desc)
  end

  def deck
    @deck   = Deck.includes(:user, deck_songs: :song).find(params[:id])
    @exports = Export.where(deck: @deck).order(created_at: :desc)
  end

  private

  def require_admin!
    redirect_to root_path, alert: "Not authorized." unless current_user.admin?
  end
end
