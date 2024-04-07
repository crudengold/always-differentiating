require_relative "api_json"

class Gameweek
  attr_reader :gw_num, :deadline
  def initialize(api_data, time_relative)
    @all_gameweeks = api_data["events"]
    @time_relative = time_relative
    @gw_num = get_number
    @deadline = get_deadline
  end

  def get_number
    @all_gameweeks.each do |num|
      if num["is_#{@time_relative}"] == true
        return num["id"]
      end
    end
  end

  def get_deadline
    @all_gameweeks.each do |num|
      if num["is_#{@time_relative}"] == true
        return Time.zone.parse(num["deadline_time"]).in_time_zone("London")
      end
    end
  end

  def illegal_players
    illegal_players = {}
    Player.all.each do |player|
      if !player.past_ownership_stats[@gw_num.to_s].nil? && player.past_ownership_stats[@gw_num.to_s] > 10
        illegal_players[player] = player.past_ownership_stats[@gw_num.to_s]
      end
    end
    illegal_players
  end

  def transfers
    transfers = {}
    Fplteam.all.each do |team|
      transfers[team.entry_name] = {in: [], out: []}
      last_week = team.picks.where("gameweek = ?", @gw_num - (team.free_hit?(team.entry, @gw_num - 1) ? 2 : 1))
      this_week = team.picks.where("gameweek = ?", @gw_num)
      transfers[team.entry_name][:out] = last_week.filter { |pick| !this_week.exists?(player_id: pick.player_id) }.pluck(:player_id)
      transfers[team.entry_name][:in] = this_week.filter { |pick| !last_week.exists?(player_id: pick.player_id) }.pluck(:player_id)
    end
    transfers
  end
end
