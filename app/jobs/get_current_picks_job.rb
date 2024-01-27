require "open-uri"

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
        next_deadline = Time.zone.parse(num["deadline_time"]).utc
      end
    end
    next_deadline_minus_one = next_deadline - 24.hours
    # go through every fplteam
    unless Pick.last.gameweek == gameweek
      puts "getting picks for gameweek #{gameweek}"
      Fplteam.all.each do |manager|
        puts "getting picks for #{manager.entry_name}"
        manager_url = "https://fantasy.premierleague.com/api/entry/#{manager.entry}/event/#{gameweek}/picks/"
        user_serialized = URI.open(manager_url).read
        all_data = JSON.parse(user_serialized)
        puts "API accessed and loaded"
        # get their picks
        all_data["picks"].each do |player|
          player_log = Player.find_by(fpl_id: player["element"])
          # create a new pick for each player
          pick = Pick.new
          pick.player = player_log
          pick.fplteam = manager
          pick.gameweek = gameweek
          pick.save
          puts "pick created for #{player_log.web_name}!"
        end
      end
    end
    UpdatePlayerStatsJob.set(wait_until: next_deadline_minus_one).perform_later
    UpdatePenaltiesJob.perform_now
    UpdateTeamScoresJob.set(wait: 1.minute).perform_later
  end
end
