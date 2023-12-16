class GetCurrentPicksJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # get the current gameweek
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    league_url = "https://fantasy.premierleague.com/api/leagues-classic/856460/standings/"
    user_serialized = URI.open(general_url).read
    all_data = JSON.parse(user_serialized)
    # get the current gameweek
    gameweek = 0
    next_deadline = ""
    all_data["events"].each do |num|
      if num["is_current"] == true
        gameweek = num["id"]
      end
    end
    all_data["events"].each do |num|
      if num["is_next"] == true
        next_deadline = num["deadline_time"]
      end
    end

    # go through every fplteam
    Fplteam.all.each do |manager|
      manager_url = "https://fantasy.premierleague.com/api/entry/#{manager.entry}/event/#{gameweek}/picks/"
      user_serialized = URI.open(manager_url).read
      all_data = JSON.parse(user_serialized)
      puts "API accessed and loaded"
      # get their picks
      all_data["picks"].each do |player|
        player_log = Player.where(fpl_id: player["element"])
        # create a new pick for each player
        pick = Pick.new
        pick.player_id = player_log[0].id
        pick.fplteam_id = manager.id
        pick.gameweek = gameweek
        pick.save
        puts "created!"
      end
    end
  end
end
