class FplteamsController < ApplicationController
  def index
    @managers = Fplteam.all
  end

  def show
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    user_serialized = URI.open(general_url).read
    all_data = JSON.parse(user_serialized)
    # get the current gameweek
    all_data["events"].each do |num|
      if num["is_previous"] == true
        @gameweek = num["id"]
        @deadline = Time.zone.parse(num["deadline_time"]).utc
      end
    end
    @manager = Fplteam.find(params[:id])
  end
end
