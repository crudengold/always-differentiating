require_relative "../services/api_json.rb"

class Fplteam < ApplicationRecord
  has_many :players, through: :picks
  has_many :picks
  has_many :penalties

  def free_hit?(team_entry, gameweek)
    url = "https://fantasy.premierleague.com/api/entry/#{team_entry}/event/#{gameweek}/picks/"
    api_data = ApiJson.new(url).get
    api_data["active_chip"] == "freehit"
  end

  def self.create_picks_for_gameweek(gameweek)
    Fplteam.all.each do |manager|
      picks = ApiJson.new("https://fantasy.premierleague.com/api/entry/#{manager.entry}/event/#{gameweek}/picks/").get["picks"]
      picks.each do |pick|
        pick_data = Player.find_by(fpl_id: pick["element"])
        # create a new pick for each player
        pick = Pick.create(player: pick_data, fplteam: manager, gameweek: gameweek)
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
