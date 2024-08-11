namespace :teams do
  desc "Get all FPL teams from the league"
  task get_fplteams: :environment do
    all_teams = ApiJson.new("https://fantasy.premierleague.com/api/leagues-classic/560149/standings/").get["new_entries"]["results"]
    all_teams.each do |team|
      unless Fplteam.find_by(entry: team["entry"])
        Fplteam.create(entry_name: team["entry_name"], entry: team["entry"], player_name: "#{team["player_first_name"]} #{team["player_last_name"]}")
        p "Created #{team["entry_name"]}"
      end
    end
  end
end
