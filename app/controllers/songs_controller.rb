class SongsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_song, only: [:show, :edit, :update, :destroy]

  def index
    scope = Song.where(import_status: "done")
    @songs = if params[:q].present?
      q = "%#{Song.sanitize_sql_like(params[:q])}%"
      scope.where("title ILIKE ? OR english_title ILIKE ? OR artist ILIKE ?", q, q, q).order(:title)
    else
      scope.order(:title)
    end
  end

  def import
    input      = params[:title].to_s.strip
    raw_lyrics = params[:raw_lyrics].to_s.strip.presence
    deck_id    = params[:deck_id].presence

    if input.blank?
      redirect_to songs_path, alert: "Please enter a song title."
      return
    end

    # Parse "Title - Artist" format
    title, artist = parse_title_artist(input)

    SearchSongJob.perform_later(title, artist: artist, raw_lyrics: raw_lyrics, deck_id: deck_id)
    redirect_to select_songs_path(title: title, artist: artist, deck_id: deck_id)
  end

  def select
    @title   = params[:title].to_s.strip
    @artist  = params[:artist].to_s.strip.presence
    @deck_id = params[:deck_id].presence
    redirect_to songs_path if @title.blank?
  end

  def confirm_import
    title      = params[:title].to_s.strip
    artist     = params[:artist].to_s.strip
    raw_lyrics = params[:raw_lyrics].to_s.strip.presence
    deck_id    = params[:deck_id].presence

    if title.blank? || artist.blank?
      redirect_to songs_path, alert: "Missing song information."
      return
    end

    ImportSongJob.perform_later(title, artist: artist, raw_lyrics: raw_lyrics, deck_id: deck_id)
    redirect_to processing_songs_path(title: title, deck_id: deck_id)
  end

  def paste
  end

  def processing
    @title   = params[:title].to_s.strip
    @deck_id = params[:deck_id].presence
    redirect_to songs_path if @title.blank?
  end

  def show
  end

  def new
    @song = Song.new
  end

  def create
    @song = Song.new(song_params)
    if @song.save
      redirect_to @song, notice: "Song created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @song.update(song_params)
      redirect_to @song, notice: "Song updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @song.destroy
    redirect_to songs_path, notice: "Song deleted."
  end

  private

  def set_song
    @song = Song.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to songs_path, notice: "That song couldn't be found. Try importing it again."
  end

  def song_params
    params.require(:song).permit(:title, :english_title, :artist, :default_key, :ccli_number,
                                 lyrics_attributes: [:id, :section_type, :content, :pinyin, :position])
  end

  def parse_title_artist(input)
    # Split on " - " or " — " (em dash)
    parts = input.split(/\s+[-—]\s+/, 2)
    if parts.length == 2
      [parts[0].strip, parts[1].strip]
    else
      [input, nil]
    end
  end
end
