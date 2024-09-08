require "open-uri"
require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"

class UpdatePenaltiesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    gameweek = Gameweek.new("current").gw_num

    Fplteam.find_each do |fplteam|
      next if fplteam.free_hit?(gameweek)

      picks_for_gw = fplteam.picks[gameweek.to_s]
      next unless picks_for_gw
      p "checking penalties for #{fplteam.discord_name}"

      picks_for_gw.each do |player_id|
        player = Player.find_by(fpl_id: player_id)
        if player.over_15_percent(gameweek)
          Penalty.create_or_update_penalty(player, gameweek, fplteam)
        elsif player.ten_to_fifteen_percent(gameweek) && player.is_new_pick(fplteam, gameweek)
          Penalty.create_or_update_penalty(player, gameweek, fplteam)
        end
      end
      p "all picks checked for gameweek #{gameweek} for team #{fplteam.id}"
    end
  end
end
