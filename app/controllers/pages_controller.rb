require "json"
require "open-uri"
require "date"
require "time"


class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    user_serialized = URI.open(general_url).read
    all_data = JSON.parse(user_serialized)
    # get the current gameweek
    all_data["events"].each do |num|
      if num["is_next"] == true
        @gameweek = num["id"]
        @deadline = Time.zone.parse(num["deadline_time"]).utc
      end
    end
    # @gameweek = 25
    @last_week = @gameweek - 1
    @deadline_minus_one = @deadline - 24.hours
    # @update_time = SelectedByStat.last.created_at
    @update_time = Player.last.updated_at
    # @illegal_players = SelectedByStat.where("selected_by > ? AND gameweek = ?", 10, @gameweek).order(selected_by: :desc)
    @illegal_players = get_illegals(@gameweek)
    @illegal_players = @illegal_players.sort_by {|_key, value| value}.reverse.to_h
    @last_week_illegal_players = get_illegals(@last_week)
    @last_week_illegal_players = @last_week_illegal_players.sort_by {|_key, value| value}.reverse.to_h
    @penalties = Penalty.where("gameweek = ?", @gameweek)
    @latest_confirmed_penalties = Penalty.where("status = 'confirmed' AND gameweek = ?", @gameweek - 1)
    @penalty_players = @penalties.distinct.pluck(:player_id)
    @transfers = get_transfers
  end

  def test
  end

  def new
  end

  def transfers
    @transfers = get_transfers
    @gameweek = get_gameweek
  end

  # There’s quite a lot of logic in this controller. Generally it’s seen as good practice to have “thin”
  # controllers and put the logic elsewhere—the model or a service object, generally. This is especially true
  # if it’s logic that might be helpful elsewhere in the application. It also helps keept things testable.

  def position(num)
    # converts the element type number into a position
    if num == 1
      return "gk"
    elsif num == 2
      return "def"
    elsif num == 3
      return "mid"
    elsif num == 4
      return "fwd"
    end
  end

  def get_gameweek
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    user_serialized = URI.open(general_url).read
    all_data = JSON.parse(user_serialized)
    # get the current gameweek
    all_data["events"].each do |num|
      if num["is_current"] == true
        return num["id"]
      end
    end
  end

  # You’re getting a subset of Players here, so this should probably be a scope on Player. See my comment over
  # there about a JSON column—that would make it easier. Otherwise, it could just be a method on Player.
  def get_illegals(gameweek)
    illegal_players = {}
    Player.all.each do |player|
      if !player.past_ownership_stats[gameweek.to_s].nil? && player.past_ownership_stats[gameweek.to_s] > 10
        illegal_players[player] = player.past_ownership_stats[gameweek.to_s]
      end
    end
    # Generally you don’t use “return” in Ruby unless you’re returning _early_ from a method. Otherwise, just
    # have the last line of the method be the return value on its own.
    return illegal_players
  end

  def get_transfers
    transfers = {}
    gameweek = get_gameweek
    # get the current gameweek
    # for each fpl team
    Fplteam.all.each do |team|
    # add team to transfers hash with empty hash as value
      team_name = team.entry_name
      transfers[team_name] = {in: [], out: []}
      # I’m being super picky, but generally I’d avoid these kinds of comments that just say what the code is doing.
      # Your code should be clear enough (and your variables well-named enough) that it’s fairly obvious. And I would
      # say that’s the case here.
      # get last week's picks
      last_week = team.picks.where("gameweek = ?", gameweek - 1)
      # get this week's picks
      this_week = team.picks.where("gameweek = ?", gameweek)
      # raise
    # compare the two
      last_week.each do |pick|
    # if a player is in last week's picks but not this week's, add to team hash as key
        if this_week.where("player_id = ?", pick.player_id).empty?
          transfers[team_name][:out] << pick.player_id
        end
    # if a player is in this week's picks but not last week's, add to team hash as value
      end
      this_week.each do |pick|
        if last_week.where("player_id = ?", pick.player_id).empty? # Normally go for the cleaner last_week.exists?(player_id: pick.player_id)
          transfers[team_name][:in] << pick.player_id
        end
      end
      # In fact, I think the 5 lines above could be done something like this (though I’ve not tested it, this likely needs refining.
      # transfers[team_name][:in] = this_week.filter { |p| last_week.exists?(player_id: p.player_id) }
    end
    # return transfers hash
    return transfers
  end
end
