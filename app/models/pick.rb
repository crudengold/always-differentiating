class Pick < ApplicationRecord
  belongs_to :player
  belongs_to :fplteam

  def over_15_percent?(gameweek)
    player.past_ownership_stats[gameweek.to_s] >= 15
  end

  def between_10_and_15_percent?(gameweek)
    player.past_ownership_stats[gameweek.to_s] < 15 && player.past_ownership_stats[gameweek.to_s] >= 10
  end

  def pick_is_new?
    Pick.where(player: player, fplteam: fplteam, gameweek: (gameweek - (fplteam.free_hit?(fplteam.entry, gameweek - 1) ? 2 : 1))).empty?
  end
end
