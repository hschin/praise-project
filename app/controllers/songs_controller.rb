class SongsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_song, only: [:show, :edit, :update, :destroy]

  def index
    scope = Song.where(import_status: "done")
    @songs = if params[:q].present?
      scope.where("title ILIKE ?", "%#{Song.sanitize_sql_like(params[:q])}%").order(:title)
    else
      scope.order(:title)
    end
  end

  def import
    title      = params[:title].to_s.strip
    raw_lyrics = params[:raw_lyrics].to_s.strip.presence

    if title.blank?
      redirect_to songs_path, alert: "Please enter a song title."
      return
    end

    ImportSongJob.perform_later(title, raw_lyrics: raw_lyrics)
    redirect_to processing_songs_path(title: title)
  end

  def processing
    @title = params[:title].to_s.strip
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
    params.require(:song).permit(:title, :artist, :default_key,
                                 lyrics_attributes: [:id, :section_type, :content, :pinyin, :position])
  end
end
