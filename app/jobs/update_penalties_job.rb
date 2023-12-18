require "open-uri"

class UpdatePenaltiesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    user_serialized = URI.open(general_url).read
    all_data = JSON.parse(user_serialized)
    # get the current gameweek
    gameweek = 0
    all_data["events"].each do |num|
      if num["is_current"] == true
        gameweek = num["id"]
      end
    end
    # so i want to go through every pick for the gameweek
    # if the pick has selected_by_stat for that gameweek of 10 or over, check for pending penalties
    # if no pending penalty, create a penalty, set to pick's fplteam
    # set status of penalty to confirmed and deduct 4 points
    all_picks_for_gw = Pick.where(gameweek: gameweek)
    all_picks_for_gw.each do |pick|
      if SelectedByStat.find_by(player: pick.player, gameweek: gameweek).selected_by >= 15
        if Penalty.where(player: pick.player, gameweek: gameweek).empty?
          penalty = Penalty.new
          penalty.points_deducted = 4
          penalty.fplteam = pick.fplteam
          penalty.player = pick.player
          penalty.status = "confirmed"
          penalty.gameweek = gameweek
          penalty.save
          puts "penalty confirmed!"
        else
          pending_penalties = Penalty.where(player: pick.player, gameweek: gameweek)
          pending_penalties.each do |penalty|
            penalty.status = "confirmed"
            penalty.points_deducted = 4
            penalty.save
            puts "penalty confirmed!"
          end
        end
      end
      if SelectedByStat.find_by(player: pick.player, gameweek: gameweek).selected_by < 15 &&
         SelectedByStat.find_by(player: pick.player, gameweek: gameweek).selected_by >= 10 &&
         Pick.where(player: pick.player, fplteam: pick.fplteam, gameweek: (gameweek - 1)).nil?
        penalty = Penalty.new
        penalty.points_deducted = 4
        penalty.fplteam = pick.fplteam
        penalty.player = pick.player
        penalty.status = "confirmed"
        penalty.gameweek = gameweek
        penalty.save
        puts "penalty confirmed!"
      end
      p "all picks checked for gameweek #{gameweek}"
    end
  end
end
