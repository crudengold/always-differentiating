require "open-uri"
require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"

class GetPendingPenaltiesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # all_data = ApiJson.new("https://fantasy.premierleague.com/api/bootstrap-static/").get
    gameweek = Gameweek.new(all_data, "next").gw_num

    illegal_players = Player.illegal_players(gameweek).sort_by {|_key, value| value}.reverse.to_h
    last_weeks_free_hitters = Fplteam.last_weeks_free_hitters(gameweek)

    Penalty.create_for_non_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
    Penalty.create_for_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
    Penalty.create_for_previous_warnings(gameweek, last_weeks_free_hitters)
  end
end
