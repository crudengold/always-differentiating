require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"

class Penalty < ApplicationRecord
  belongs_to :fplteam
  belongs_to :player

  scope :confirmed, -> { where(status: "confirmed") }

  POINTS_DEDUCTED = 4

  def self.create_or_update_penalty(pick, gameweek, data)
    next_gameweek = Gameweek.new(data, "next")
    next_deadline = next_gameweek.deadline - 1.day

    if pick.over_15_percent?
      create_penalty(pick, gameweek)
      schedule_update_job(next_gameweek, next_deadline)
    elsif pick.between_10_and_15_percent? && pick.is_new?
      create_penalty(pick, gameweek)
      schedule_update_job(next_gameweek, next_deadline)
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

  private

  def self.create_penalty(pick, gameweek)
    Penalty.create(points_deducted: POINTS_DEDUCTED, fplteam: pick.fplteam, player: pick.player, status: "confirmed", gameweek: gameweek)
  end

  def self.schedule_update_job(next_gameweek, deadline)
    return if next_gameweek.gw_num == 38

    UpdatePenaltyPointsJob.set(wait_until: deadline).perform_later(Penalty.last)
  end
end
