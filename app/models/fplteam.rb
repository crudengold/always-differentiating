class Fplteam < ApplicationRecord
  has_many :players, through: :picks
  has_many :picks
  has_many :penalties

  def free_hit?(api_data)
    api_data["active_chip"] == "freehit"
  end


end
