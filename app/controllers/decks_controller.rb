class DecksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deck, only: [:show, :edit, :update, :destroy, :export]

  def index
    @decks = current_user.decks.order(date: :desc)
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
      redirect_to @deck, notice: "Deck updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deck.destroy
    redirect_to decks_path, notice: "Deck deleted."
  end

  def export
    # PPTX generation — to be implemented
    head :ok
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:id])
  end

  def deck_params
    params.require(:deck).permit(:title, :date, :notes)
  end
end
