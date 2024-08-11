namespace :teams do
  desc "Input the manager's Discord name for each FPL team"
  task get_fplteam_discord_names: :environment do
    Fplteam.all.each do |fplteam|
      current_name = fplteam.discord_name || ""
      print "Enter Discord name for #{fplteam.entry_name} – #{fplteam.player_name} (current: @#{current_name}): "
      input = STDIN.gets.chomp
      fplteam.update(discord_name: input.empty? ? current_name : input)
    end
  end
end
