class Fplteam < ApplicationRecord
  has_many :players, through: :picks
  has_many :picks
  has_many :penalties

  def free_hit?(team_entry, gameweek)
    url = "https://fantasy.premierleague.com/api/entry/#{team_entry}/event/#{gameweek}/picks/"
    api_data = ApiJson.new(url).get
    api_data["active_chip"] == "freehit"
  end


end
