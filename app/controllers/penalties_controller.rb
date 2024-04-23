class PenaltiesController < ApplicationController
  def index
    @penalties = Penalty.where(status: "confirmed")
  end

  def show
    @penalty = Penalty.find(params[:id])
  end

  def new
    @penalty = Penalty.new
  end

  def create
    @penalty = Penalty.new(penalty_params)
    if @penalty.save
      redirect_to @penalty
    else
      render :new
    end
  end

  def edit
    @penalty = Penalty.find(params[:id])
  end

  def update
    @penalty = Penalty.find(params[:id])
    if @penalty.update(penalty_params)
      redirect_to @penalty
    else
      render :edit
    end
  end

  def destroy
    @penalty = Penalty.find(params[:id])
    @penalty.destroy
    redirect_to penalties_path
  end

  private

  def penalty_params
    params.require(:penalty).permit(:fplteam, :player, :gameweek, :points_deducted)
  end
end
