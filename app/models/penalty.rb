require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"

class Penalty < ApplicationRecord
  belongs_to :fplteam
  belongs_to :player


  def self.create_or_update_penalty(pick, gameweek)
    gw_data = ApiJson.new("https://fantasy.premierleague.com/api/bootstrap-static/").get
    next_deadline = Gameweek.new(gw_data, "next").deadline

    if pick.player.past_ownership_stats[gameweek.to_s] >= 15
      if Penalty.where(player: pick.player, gameweek: gameweek, fplteam: pick.fplteam).empty?
        penalty = Penalty.new
        penalty.points_deducted = 4
        penalty.fplteam = pick.fplteam
        penalty.player = pick.player
        penalty.status = "confirmed"
        penalty.gameweek = gameweek
        penalty.save
        UpdatePenaltyPointsJob.set(wait_until: next_deadline).perform_later(penalty)
        puts "penalty confirmed!"
      else
        pending_penalties = Penalty.where(player: pick.player, gameweek: gameweek, fplteam: pick.fplteam)
        pending_penalties.each do |penalty|
          penalty.status = "confirmed"
          penalty.points_deducted = 4
          penalty.save
          UpdatePenaltyPointsJob.set(wait_until: next_deadline).perform_later(penalty)
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
      UpdatePenaltyPointsJob.set(wait_until: next_deadline - 24.hours).perform_later(penalty)
      puts "penalty confirmed!"
    end
  end

  def update_deducted_points
    player_data = ApiJson.new("https://fantasy.premierleague.com/api/element-summary/#{self.player.id}/").get["history"]
    gameweek_score = player_data.select { |gw| gw["round"] == self.gameweek }.first["total_points"]
    self.points_deducted += gameweek_score
    self.save
  end
end
