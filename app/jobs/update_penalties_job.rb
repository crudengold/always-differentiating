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
      if pick.player.past_ownership_stats[gameweek.to_s] >= 15
        if Penalty.where(player: pick.player, gameweek: gameweek, fplteam: pick.fplteam).empty?
          penalty = Penalty.new
          penalty.points_deducted = 4
          penalty.fplteam = pick.fplteam
          penalty.player = pick.player
          penalty.status = "confirmed"
          penalty.gameweek = gameweek
          penalty.save
          puts "penalty confirmed!"
        else
          pending_penalties = Penalty.where(player: pick.player, gameweek: gameweek, fplteam: pick.fplteam)
          pending_penalties.each do |penalty|
            penalty.status = "confirmed"
            penalty.points_deducted = 4
            penalty.save
            puts "penalty confirmed!"
          end
        end
      end

      if pick.player.past_ownership_stats[gameweek.to_s] < 15 &&
         pick.player.past_ownership_stats[gameweek.to_s] >= 10 &&
         Pick.where(player: pick.player, fplteam: pick.fplteam, gameweek: (gameweek - (pick.fplteam.free_hit?(pick.fplteam.entry, gameweek - 1) ? 2 : 1))).nil?
        penalty = Penalty.new
        penalty.points_deducted = 4
        penalty.fplteam = pick.fplteam
        penalty.player = pick.player
        penalty.status = "confirmed"
        penalty.gameweek = gameweek
        penalty.save
        puts "penalty confirmed!"
      end
      p "all picks checked for gameweek #{gameweek}"
    end
  end
end
