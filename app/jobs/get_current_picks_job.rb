require "open-uri"
require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"
require_relative "../services/fetch_api_data.rb"
require_relative "../helpers/json_helper.rb"

class GetCurrentPicksJob < ApplicationJob
  queue_as :default

  def perform(*args)
    url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    fetch_api_data = FetchApiData.new(url)
    fetch_api_data.clear_cache
    fetch_api_data.call

    gameweek = Gameweek.new("current").gw_num
    next_gameweek = Gameweek.new("next")
    next_deadline = next_gameweek.deadline
    next_deadline_minus_one = next_deadline - 24.hours

    unless Fplteam&.last&.picks&.keys&.last == gameweek.to_s
      puts "getting picks for gameweek #{gameweek}"
      Fplteam.create_picks_for_gameweek(gameweek)
    end

    unless gameweek == 38
      UpdatePlayerStatsJob.set(wait_until: next_deadline_minus_one).perform_later
    end

    UpdatePenaltiesJob.perform_now
    UpdateTeamScoresJob.set(wait: 1.minute).perform_later
  end
end
