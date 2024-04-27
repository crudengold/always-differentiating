require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"

class Penalty < ApplicationRecord
  belongs_to :fplteam
  belongs_to :player

  def self.create_or_update_penalty(pick, gameweek, data)
    next_deadline = Gameweek.new(data, "next").deadline - 1.day
    if pick.player.past_ownership_stats[gameweek.to_s] >= 15
      if Penalty.where(player: pick.player, gameweek: gameweek, fplteam: pick.fplteam).empty?
        Penalty.create(points_deducted: 4, fplteam: pick.fplteam, player: pick.player, status: "confirmed", gameweek: gameweek)
        UpdatePenaltyPointsJob.set(wait_until: next_deadline).perform_later(Penalty.last)
      else
        pending_penalties = Penalty.where(player: pick.player, gameweek: gameweek, fplteam: pick.fplteam)
        pending_penalties.each do |penalty|
          penalty.status = "confirmed"
          penalty.points_deducted = 4
          penalty.save
          UpdatePenaltyPointsJob.set(wait_until: next_deadline).perform_later(penalty)
        end
      end
    end
    if pick.player.past_ownership_stats[gameweek.to_s] < 15 &&
      pick.player.past_ownership_stats[gameweek.to_s] >= 10 &&
      Pick.where(player: pick.player, fplteam: pick.fplteam, gameweek: (gameweek - (pick.fplteam.free_hit?(pick.fplteam.entry, gameweek - 1) ? 2 : 1))).empty?
      Penalty.create(points_deducted: 4, fplteam: pick.fplteam, player: pick.player, status: "confirmed", gameweek: gameweek)
      UpdatePenaltyPointsJob.set(wait_until: next_deadline - 24.hours).perform_later(Penalty.last)
    end
  end

  def update_deducted_points
    player_data = ApiJson.new("https://fantasy.premierleague.com/api/element-summary/#{self.player.id}/").get["history"]
    gameweek_score = player_data.select{ |gw| gw["round"] == self.gameweek }.first["total_points"]
    self.points_deducted += gameweek_score
    self.save
  end

  def self.create_for_non_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
    Pick.where(gameweek: gameweek - 1).each do |pick|
      if illegal_players.include?(pick.player) && !last_weeks_free_hitters.include?(pick.fplteam)
        create(player: pick.player, fplteam: pick.fplteam, gameweek: gameweek)
      end
    end
  end

  def self.create_for_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
    Pick.where(gameweek: gameweek - 2).each do |pick|
      if illegal_players.include?(pick.player) && last_weeks_free_hitters.include?(pick.fplteam)
        create(player: pick.player, fplteam: pick.fplteam, gameweek: gameweek)
      end
    end
  end

  def self.create_for_previous_warnings(gameweek, last_weeks_free_hitters)
    last_weeks_free_hitters.each do |fplteam|
      where(fplteam: fplteam, gameweek: gameweek - 1).each do |warning|
        unless where(player: warning.player, fplteam: warning.fplteam, gameweek: gameweek).exists?
          create(player: warning.player, fplteam: warning.fplteam, gameweek: gameweek)
        end
      end
    end
  end
end
