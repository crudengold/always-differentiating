class PenaltiesController < ApplicationController
  before_action :set_penalty, only: [:show, :edit, :update, :destroy]

  def index
    @penalties = Penalty.where(status: "confirmed").sort_by(&:gameweek).reverse
  end

  def show
  end

  def new
    @penalty = Penalty.new
  end

  def create
    @penalty = Penalty.new(penalty_params)
    if @penalty.save
      redirect_to penalties_path, notice: "Penalty was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @penalty.update(penalty_params)
      redirect_to penalties_path, notice: "Penalty was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @penalty.destroy
    redirect_to penalties_path
  end

  private

  def set_penalty
    @penalty = Penalty.find(params[:id])
  end

  def penalty_params
    params.require(:penalty).permit(:fplteam_id, :player_id, :gameweek, :points_deducted, :status)
  end
end
