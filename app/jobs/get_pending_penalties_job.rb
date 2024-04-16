require "open-uri"
require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"

class GetPendingPenaltiesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    all_data = ApiJson.new("https://fantasy.premierleague.com/api/bootstrap-static/").get
    gameweek = Gameweek.new(all_data, "next").gw_num

    illegal_players = {}

    Player.all.each do |player|
      if !player.past_ownership_stats[gameweek.to_s].nil? && player.past_ownership_stats[gameweek.to_s] >= 15
        illegal_players[player] = player.past_ownership_stats[gameweek.to_s]
      end
    end

    illegal_players = illegal_players.sort_by {|_key, value| value}.reverse

    last_weeks_free_hitters = Fplteam.all.select do |fplteam|
      fplteam.free_hit?(fplteam.entry, gameweek - 1)
    end

    # Check non free-hitters
    Pick.where(gameweek: gameweek - 1).each do |pick|
      if illegal_players.include?(pick.player) && !last_weeks_free_hitters.include?(pick.fplteam)
        Penalty.create(player: pick.player, fplteam: pick.fplteam, gameweek: gameweek)
      end
    end

    # Check free-hitters
    Pick.where(gameweek: gameweek - 2).each do |pick|
      if illegal_players.include?(pick.player) && last_weeks_free_hitters.include?(pick.fplteam)
        Penalty.create(player: pick.player, fplteam: pick.fplteam, gameweek: gameweek)
      end
    end

    last_weeks_free_hitters.each do |fplteam|
      # if the team had a warning last week, create the same warning for this week, unless it already exists
      Penalty.where(fplteam: fplteam, gameweek: gameweek - 1).each do |warning|
        unless Penalty.where(player: warning.player, fplteam: warning.fplteam, gameweek: gameweek).exists?
          Penalty.create(player: warning.player, fplteam: warning.fplteam, gameweek: gameweek)
        end
      end
    end
  end
end
