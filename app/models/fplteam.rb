require_relative "../services/api_json.rb"

class Fplteam < ApplicationRecord
  has_many :players, through: :picks
  # has_many :picks
  has_many :penalties

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
      picks = ApiJson.new("https://fantasy.premierleague.com/api/entry/#{manager.entry}/event/#{gameweek}/picks/").get["picks"]
      picks.each do |pick|
        pick_data = Player.find_by(fpl_id: pick["element"])
        # create a new pick for each player
        manager.picks["#{gameweek}"] << pick_data
      end
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

end
