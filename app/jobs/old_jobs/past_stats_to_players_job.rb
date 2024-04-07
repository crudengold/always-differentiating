class PastStatsToPlayersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # go through each player
    # get every selected_by_stat for that player
    # add the gameweek for the selected_by_stat to the player's past_ownership_stats hash as a key
    # add the selected_by for the selected_by_stat to the player's past_ownership_stats hash as a value
    Player.all.each do |player|
      stats = {}
      player.selected_by_stats.each do |stat|
        stats[stat.gameweek.to_i] = stat.selected_by
      end
      player.past_ownership_stats = stats
      player.save
    end
  end
end
