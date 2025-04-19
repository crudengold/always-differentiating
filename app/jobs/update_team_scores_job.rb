require "open-uri"
require_relative "../services/api_json.rb"

class UpdateTeamScoresJob < ApplicationJob
  queue_as :default

  def perform(*args)
    teams = ApiJson.new("https://fantasy.premierleague.com/api/leagues-classic/560149/standings/").get["standings"]["results"]
    update_penalties(teams)
    update_scores(teams)
  end

  def update_penalties(teams)
    teams.each do |team|
      fplteam = Fplteam.find_by(entry: team["entry"])
      fplteam.update_penalties if fplteam
    end
  end

  def update_scores(teams)
    teams.each do |team|
      fplteam = Fplteam.find_by(entry: team["entry"])
      fplteam.update_scores(team["total"]) if fplteam
    end
  end
end
