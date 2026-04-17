class DecksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deck, only: [ :show, :edit, :update, :destroy, :export, :download_export ]

  def index
    @decks = current_user.decks.order(date: :desc)
    @song = Song.find_by(id: params[:song_id]) if params[:song_id]
  end

  def show
  end

  def new
    next_sunday = Date.today.next_occurring(:sunday)
    @deck = current_user.decks.new(date: next_sunday)
  end

  def create
    @deck = current_user.decks.new(deck_params)
    if @deck.save
      redirect_to @deck, notice: "Deck created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @deck.update(deck_params)
      respond_to do |format|
        format.html { redirect_to @deck, notice: "Deck updated." }
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @deck.destroy
    redirect_to decks_path, notice: "Deck deleted."
  end

  def quick_create
    @deck = current_user.decks.new(
      title: upcoming_sunday_title,
      date:  upcoming_sunday_date
    )
    if @deck.save
      redirect_to @deck
    else
      redirect_to decks_path, alert: "Could not create deck."
    end
  end

  def export
    Export.create!(deck: @deck, user: current_user, event: :generated)
    GeneratePptxJob.perform_later(@deck.id)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "export_button_#{@deck.id}",
          partial: "decks/export_button",
          locals: { deck: @deck, state: :generating }
        )
      end
      format.html { redirect_to @deck, notice: "Generating PPTX..." }
    end
  end

  def download_export
    token = params[:token].to_s.gsub(/[^a-zA-Z0-9_\-]/, "")
    path = Rails.cache.read("pptx_export_#{token}")

    safe_path = Pathname.new(path.to_s).expand_path
    allowed_dir = Pathname.new(Dir.tmpdir).expand_path

    if path.nil? || !safe_path.to_s.start_with?(allowed_dir.to_s) || !safe_path.exist?
      redirect_to @deck, alert: "Download link expired. Please re-export."
      return
    end

    Export.create!(deck: @deck, user: current_user, event: :downloaded)
    filename = "#{@deck.title.parameterize}-export.pptx"
    send_file safe_path,
      filename: filename,
      type: "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      disposition: "attachment"
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:id])
  end

  def deck_params
    params.require(:deck).permit(:title, :date, :notes, :show_pinyin, :lines_per_slide)
  end

  def upcoming_sunday_date
    today = Date.today
    today.sunday? ? today : today.next_occurring(:sunday)
  end

  def upcoming_sunday_title
    date = upcoming_sunday_date
    base = "Sunday #{date.day} #{date.strftime('%B')}"
    existing = current_user.decks.where("title LIKE ?", "#{base}%").pluck(:title)
    return base unless existing.include?(base)
    n = 1
    n += 1 while existing.include?("#{base} (#{n})")
    "#{base} (#{n})"
  end
end
