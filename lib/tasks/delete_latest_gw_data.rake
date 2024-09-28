namespace :data do
  desc "Get all FPL data from the api"
  task delete_latest_gw: :environment do
    Player.all.each do |player|
      past_ownership_stats_array = player.past_ownership_stats.to_a
      past_ownership_stats_array.pop
      player.past_ownership_stats = past_ownership_stats_array.to_h
      player.save
    end
  end
end
