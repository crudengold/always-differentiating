class FplteamsController < ApplicationController
  def index
    @managers = Fplteam.all
  end

  def show
    @gameweek = 19
    @manager = Fplteam.find(params[:id])
  end
end
