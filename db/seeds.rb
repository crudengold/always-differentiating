# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
league_url = "https://fantasy.premierleague.com/api/leagues-classic/856460/standings/"


# Pick.destroy_all

# Fplteam.all.each do |manager|
#   url = "https://fantasy.premierleague.com/api/entry/#{manager.entry}/event/12/picks/"
#   user_serialized = URI.open(url).read
#   all_data = JSON.parse(user_serialized)
#   puts "API accessed and loaded"
#   all_data["picks"].each do |player|
#     player_log = Player.where(fpl_id: player["element"])
#     puts player_log[0].web_name
#     pick = Pick.new
#     pick.player_id = player_log[0].id
#     pick.fplteam_id = manager.id
#     pick.save
#     puts "created!"
#   end
# end


# all_data["elements"].each do |player|
#   new_player = Player.new
#   new_player.web_name = player["web_name"]
#   puts "#{new_player.web_name} created"
#   new_player.code = player["code"]
#   new_player.element_type = player["element_type"]
#   new_player.event_points = player["event_points"]
#   new_player.first_name = player["first_name"]
#   new_player.fpl_id = player["id"]
#   new_player.photo = player["photo"]
#   new_player.second_name = player["second_name"]
#   new_player.selected_by_percent = player["selected_by_percent"]
#   new_player.team = player["team"]
#   new_player.total_points = player["total_points"]
#   new_player.save
#   puts "#{new_player.web_name} finished\n"
# end

# all_data["standings"]["results"].each do |manager|
#   new_manager = Fplteam.new
#   new_manager.event_total = manager["event_total"]
#   new_manager.player_name = manager["player_name"]
#   new_manager.rank = manager["rank"]
#   new_manager.last_rank = manager["last_rank"]
#   new_manager.rank_sort = manager["rank_sort"]
#   new_manager.total = manager["total"]
#   new_manager.entry = manager["entry"]
#   new_manager.entry_name = manager["entry_name"]
#   new_manager.save
#   puts "Saved #{new_manager.entry_name} (#{new_manager.player_name})"
# end


user_serialized = URI.open(general_url).read
all_data = JSON.parse(user_serialized)

all_data["elements"].each do |player|
  player_data = Player.where(fpl_id: player["id"])
  puts player_data[0].id
  # puts player_data[0].shirt
  # player_data.shirt = player["team_code"]
  # player_date.save!
  # p "shirt added for #{player["web_name"]}"
end
