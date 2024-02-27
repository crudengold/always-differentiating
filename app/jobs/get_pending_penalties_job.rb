require "open-uri"

class GetPendingPenaltiesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    # find picks where player has selected_by > 15
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    user_serialized = URI.open(general_url).read
    all_data = JSON.parse(user_serialized)
    # get the current gameweek
    gameweek = 0
    all_data["events"].each do |num|
      if num["is_next"] == true
        gameweek = num["id"]
      end
    end
    #get all illegal players
    # illegal_players = SelectedByStat.where("selected_by > 15 AND gameweek = ?", gameweek)
    illegal_players = {}
    Player.all.each do |player|
      if !player.past_ownership_stats["23"].nil? && player.past_ownership_stats["23"] > 10
        illegal_players[player] = player.past_ownership_stats["23"]
      end
    end
    illegal_players = illegal_players.sort_by {|_key, value| value}.reverse

    illegal_players.each do |player|
      # find picks where player is selected, and skip if there are none
      unless Pick.find_by(player: player[0], gameweek: gameweek - 1).nil?
        # create pending penalty for each pick's manager
        Pick.where(player: player[0], gameweek: gameweek - 1).each do |pick|
          warning = Penalty.new
          warning.player = player[0]
          warning.fplteam = pick.fplteam
          warning.gameweek = gameweek
          warning.save
          puts "Penalty created for #{warning.fplteam.player_name}, #{warning.player.web_name}"
        end
      end
    end
  end
end
