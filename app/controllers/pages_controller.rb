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
    @deadline_minus_one = @deadline - 24.hours
    @update_time = SelectedByStat.last.created_at
    @illegal_players = SelectedByStat.where("selected_by > ? AND gameweek = ?", 10, @gameweek).order(selected_by: :desc)
    @penalties = Penalty.where("gameweek = ?", @gameweek)
    @latest_confirmed_penalties = Penalty.where("status = 'confirmed' AND gameweek = ?", @gameweek - 1)
    @penalty_players = @penalties.distinct.pluck(:player_id)
  end

  def test
  end

  def new
  end

  def transfers
    @transfers = get_transfers
  end

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

  def get_transfers
    transfers = {}
    # get the current gameweek
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    user_serialized = URI.open(general_url).read
    all_data = JSON.parse(user_serialized)
    # get the current gameweek
    all_data["events"].each do |num|
      if num["is_current"] == true
        @gameweek = num["id"]
      end
    end
    # for each fpl team
    Fplteam.all.each do |team|
    # add team to transfers hash with empty hash as value
      transfers[team.entry_name] = {in: [], out: []}
    # get last week's picks
      last_week = team.picks.where("gameweek = ?", @gameweek - 1)
    # get this week's picks
      this_week = team.picks.where("gameweek = ?", @gameweek)
    # compare the two
      raise
      last_week.each do |pick|
    # if a player is in last week's picks but not this week's, add to team hash as key
        if this_week.where("player_id = ?", pick.player_id).empty?
          transfers[team][:out] << pick.player_id
        end
    # if a player is in this week's picks but not last week's, add to team hash as value
        if last_week.where("player_id = ?", pick.player_id).empty?
          transfers[team][:in] << pick.player_id
        end
      end
    end
    # return transfers hash
    return transfers
  end
end
