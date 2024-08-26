require "open-uri"
require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"

class UpdatePlayerStatsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    all_data = ApiJson.new("https://fantasy.premierleague.com/api/bootstrap-static/").get
    next_gameweek = Gameweek.new(all_data, "next")
    gameweek_no = next_gameweek.gw_num
    deadline = next_gameweek.deadline
    after_deadline = deadline + 90.minutes

    if Player.first.nil? || Player.find_by(web_name: "Haaland")&.past_ownership_stats&.key?(gameweek_no) == false
      all_data["elements"].each do |player|
        Player.create_or_update_player(player, gameweek_no)
      end
    else
      print "Stats already logged for Gameweek #{gameweek_no}"
    end

    # GetPendingPenaltiesJob.perform_now
    GetCurrentPicksJob.set(wait_until: after_deadline).perform_later
  end
end
