require "open-uri"
require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"

class UpdatePenaltiesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    all_data = ApiJson.new("https://fantasy.premierleague.com/api/bootstrap-static/").get
    gameweek = Gameweek.new(all_data, "current").gw_num

    all_picks_for_gw = Pick.where(gameweek: gameweek)

    all_picks_for_gw.each do |pick|
      Penalty.create_or_update_penalty(pick, gameweek)
      p "all picks checked for gameweek #{gameweek}"
    end
  end
end
