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
    illegal_players = SelectedByStat.where("selected_by > 15 AND gameweek = ?", gameweek)

    illegal_players.each do |stat|
      #find picks where player is selected, and skip if there are none
      unless Pick.find_by(player: stat.player, gameweek: gameweek - 1).nil?
        #create pending penalty for each pick's manager
        Pick.where(player: stat.player, gameweek: gameweek - 1).each do |pick|
          warning = Penalty.new
          warning.player = stat.player
          warning.fplteam = pick.fplteam
          warning.gameweek = gameweek
          warning.save
          puts "Penalty created for #{warning.fplteam.player_name}, #{warning.player.web_name}"
        end
      end
    end
  end
end
