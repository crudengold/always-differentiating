require "open-uri"

class UpdateTeamScoresJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # gets the data from the api
    league_url = "https://fantasy.premierleague.com/api/leagues-classic/856460/standings/"
    user_serialized = URI.open(league_url).read
    all_data = JSON.parse(user_serialized)
    teams = all_data["standings"]["results"]
    update_penalties(teams)
    update_scores(teams)
  end

  def update_penalties(teams)
    # for each team in the api
    teams.each do |team|
      # find the fplteam in the database
      fplteam = Fplteam.find_by(entry: team["entry"])
      # set a total to 0
      total = 0
      # unless the team in the database has no penalties
      unless Penalty.where(fplteam: fplteam, status: "confirmed").empty?
        # for each penalty in the database for that team, add the points deducted to the total
        Penalty.where(fplteam: fplteam, status: "confirmed").each {|penalty| total += penalty.points_deducted}
      end
      # update the fplteam's deductions
      fplteam.deductions = total
      # save the fplteam
      fplteam.save
    end
  end

  def update_scores(teams)
    # for each team in the api
    teams.each do |team|
      # find the fplteam in the database
      fplteam = Fplteam.find_by(entry: team["entry"])
      # update the fplteam's total
      fplteam.total = team["total"]
      # update the fplteam's total after deductions
      fplteam.total_after_deductions = fplteam.total - fplteam.deductions
      # save the fplteam
      fplteam.save
    end
  end
end
