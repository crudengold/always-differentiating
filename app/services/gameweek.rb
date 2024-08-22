require_relative "api_json"
require 'json'

class Gameweek
  attr_reader :gw_num, :deadline
  def initialize(api_data = nil, time_relative)
    @all_gameweeks = api_data ? api_data["events"] : load_json_data
    @time_relative = time_relative
    @gw_num = get_number
    @deadline = get_deadline
  end

  def get_number
    return find_gameweek_id if @all_gameweeks.any?

    last_pick_key = Fplteam.last.picks.keys.last.to_i
    adjustments = { "current" => 0, "next" => 1, "previous" => -1 }
    last_pick_key + adjustments.fetch(@time_relative, 0)
  end

  def get_deadline
    @all_gameweeks.each do |num|
      if num["is_#{@time_relative}"] == true
        return Time.zone.parse(num["deadline_time"]).in_time_zone("London")
      end
    end
    return Time.zone.parse("2024-05-19T13:30:00Z").in_time_zone("London")
  end

  def illegal_players
    illegal_players = {}
    Player.all.each do |player|
      if !player.past_ownership_stats[@gw_num.to_s].nil? && player.past_ownership_stats[@gw_num.to_s] >= 10
        illegal_players[player] = player.past_ownership_stats[@gw_num.to_s]
      end
    end
    illegal_players
  end

  def transfers
    transfers = {}
    Fplteam.all.each do |team|
      transfers[team.entry_name] = { in: [], out: [] }

      last_week_key = (@gw_num - (team.free_hit?(@gw_num - 1) ? 2 : 1)).to_s
      this_week_key = @gw_num.to_s

      last_week = team.picks[last_week_key] || []
      this_week = team.picks[this_week_key] || []

      last_week_player_ids = last_week.map { |player| player["id"] }
      this_week_player_ids = this_week.map { |player| player["id"] }

      transfers[team.entry_name][:out] = last_week_player_ids - this_week_player_ids
      transfers[team.entry_name][:in] = this_week_player_ids - last_week_player_ids
    end
    transfers
  end

  private

  def load_json_data
    file_path = Rails.root.join('lib', 'assets', 'data', 'events.json')
    JSON.parse(File.read(file_path))["events"]
  end

  def find_gameweek_id
    @all_gameweeks.each do |num|
      return num["id"] if num["is_#{@time_relative}"]
    end
    38
  end
end
