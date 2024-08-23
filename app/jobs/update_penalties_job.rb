require "open-uri"
require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"

class UpdatePenaltiesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    gameweek = Gameweek.new("current").gw_num

    Fplteam.find_each do |fplteam|
      picks_for_gw = fplteam.picks[gameweek.to_s]

      next unless picks_for_gw

      picks_for_gw.each do |player|
        Penalty.create_or_update_penalty(player, gameweek)
        p "all picks checked for gameweek #{gameweek} for team #{fplteam.id}"
      end
    end
  end
end
