class FplteamsController < ApplicationController
  def index
    @managers = Fplteam.all
  end

  def show
    @manager = Fplteam.find(params[:id])
  end
end
