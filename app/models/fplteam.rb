require_relative "../services/api_json.rb"

class Fplteam < ApplicationRecord
  has_many :players, through: :picks
  # has_many :picks
  has_many :penalties, dependent: :destroy

  def picks_for_last_week(current_gw)
    last_week_key = (current_gw - (free_hit?(current_gw - 1) ? 2 : 1)).to_s
    picks[last_week_key] || []
  end

  def picks_for_this_week(current_gw)
    this_week_key = current_gw.to_s
    picks[this_week_key] || []
  end

  def free_hit?(gameweek)
    return false if gameweek < 2
    url = "https://fantasy.premierleague.com/api/entry/#{self.entry}/event/#{gameweek}/picks/"
    api_data = ApiJson.new(url).get
    api_data["active_chip"] == "freehit"
  end

  def self.last_weeks_free_hitters(gameweek)
    all.select { |fplteam| fplteam.free_hit?(gameweek - 1) }
  end

  def self.create_picks_for_gameweek(gameweek)
    Fplteam.all.each do |manager|

      next if manager.picks["#{gameweek}"]
      manager.picks["#{gameweek}"] = []
      picks = ApiJson.new("https://fantasy.premierleague.com/api/entry/#{manager.entry}/event/#{gameweek}/picks/").get["picks"]
      picks.each do |pick|
        manager.picks["#{gameweek}"] << pick["element"]
      end
      manager.save
    end
  end

  def update_penalties
    total = 0
    unless Penalty.where(fplteam: self, status: "confirmed").empty?
      Penalty.where(fplteam: self, status: "confirmed").each {|penalty| total += penalty.points_deducted}
    end
    self.deductions = total
    self.save
  end

  def update_scores(team_total)
    self.total = team_total
    self.total_after_deductions = self.total - self.deductions
    self.save
  end

  def average_ownership_for_gameweek(gameweek)
    total = self.picks_for_this_week(gameweek).sum do |player_id|
      player = Player.find_by(fpl_id: player_id)
      player.element_type == 5 ? 0 : player.past_ownership_stats[gameweek.to_s]
    end
    (total / 15).round(2)
  end

  def total_average_ownership
    total = self.picks.keys.map do |gameweek|
      self.average_ownership_for_gameweek(gameweek)
    end.sum
    (total / self.picks.keys.count).round(2)
  end
end
