require "open-uri"

class UpdateTeamScoresJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    league_url = "https://fantasy.premierleague.com/api/leagues-classic/856460/standings/"
    user_serialized = URI.open(league_url).read
    all_data = JSON.parse(user_serialized)
    teams = all_data["standings"]["results"]
    teams.each do |team|
      fplteam = Fplteam.find_by(entry: team["entry"])
      fplteam.total = team["total"]
      fplteam.save
    end
  end
end
