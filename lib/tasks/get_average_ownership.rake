namespace :teams do
  desc "Get the average ownership across the season for all teams from the league"
  task get_average_ownership: :environment do
    all_teams_average = {}
    Fplteam.all.each do |team|
      all_teams_average[team.discord_name] = team.total_average_ownership
    end
    all_teams_average.sort_by { |key, value| value }.each do |key, value|
      p(key+": "+value.to_s)
    end
  end
end
