# lib/tasks/migrate_picks.rake
namespace :migrate do
  desc "Migrate Pick records to the picks column in Fplteam"
  task migrate_picks: :environment do
    Fplteam.find_each do |fplteam|
      fplteam.picks = {}
      picks_hash = {}

      Pick.where(fplteam: fplteam).each do |pick|
        gameweek = pick.gameweek.to_s
        picks_hash[gameweek] ||= []
        picks_hash[gameweek] << pick.player.fpl_id
      end

      fplteam.update(picks: picks_hash)
    end

    puts "Migration completed successfully."
  end
end
