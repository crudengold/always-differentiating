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
      # if the selected by stat for that pick is 15 or over
      if pick.player.past_ownership_stats[gameweek.to_s] >= 15
      # if SelectedByStat.find_by(player: pick.player, gameweek: gameweek).selected_by >= 15
        # if there is no pending penalty for that player for that gameweek
        if Penalty.where(player: pick.player, gameweek: gameweek, fplteam: pick.fplteam).empty?
          # create a penalty
          penalty = Penalty.new
          # set the points deducted to 4
          penalty.points_deducted = 4
          # set the fplteam to the pick's fplteam
          penalty.fplteam = pick.fplteam
          # set the player to the pick's player
          penalty.player = pick.player
          # set the status to confirmed
          penalty.status = "confirmed"
          # set the gameweek to the current gameweek
          penalty.gameweek = gameweek
          # save the penalty
          penalty.save
          puts "penalty confirmed!"
        else
          # if there is a pending penalty for that player for that gameweek
          # set the status of the penalty to confirmed
          # set the points deducted to 4
          # save the penalty
          pending_penalties = Penalty.where(player: pick.player, gameweek: gameweek, fplteam: pick.fplteam)
          pending_penalties.each do |penalty|
            penalty.status = "confirmed"
            penalty.points_deducted = 4
            penalty.save
            puts "penalty confirmed!"
          end
        end
      end
      # if the selected by stat for that pick is 10 or over, but less than 15, and there is no pick for that player for the previous gameweek
      if pick.player.past_ownership_stats[gameweek.to_s] < 15 &&
         pick.player.past_ownership_stats[gameweek.to_s] >= 10 &&
         Pick.where(player: pick.player, fplteam: pick.fplteam, gameweek: (gameweek - 1)).nil?
        # create a penalty
        # set the points deducted to 4
        # set the fplteam to the pick's fplteam
        # set the player to the pick's player
        # set the status to confirmed
        # set the gameweek to the current gameweek
        # save the penalty
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
