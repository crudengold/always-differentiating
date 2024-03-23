require "json"
require "open-uri"
require "date"
require "time"
require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"


class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    all_data = ApiJson.new("https://fantasy.premierleague.com/api/bootstrap-static/").get
    previous_gw = Gameweek.new(all_data, "previous")
    current_gw = Gameweek.new(all_data, "current")
    next_gw = Gameweek.new(all_data, "next")
    @gameweek = next_gw.gw_num
    @deadline = next_gw.deadline
    @deadline_minus_one = @deadline - 24.hours
    @update_time = Player.last.updated_at
    @illegal_players = next_gw.illegal_players
    @illegal_players = @illegal_players.sort_by {|_key, value| value}.reverse.to_h
    @last_week_illegal_players = current_gw.illegal_players
    @last_week_illegal_players = @last_week_illegal_players.sort_by {|_key, value| value}.reverse.to_h
    @penalties = Penalty.where("gameweek = ?", @gameweek)
    @latest_confirmed_penalties = Penalty.where("status = 'confirmed' AND gameweek = ?", @gameweek - 1)
    @penalty_players = @penalties.distinct.pluck(:player_id)
    @transfers = current_gw.transfers
  end

  def test
  end

  def new
  end

  def transfers
    all_data = ApiJson.new("https://fantasy.premierleague.com/api/bootstrap-static/").get
    @gameweek = Gameweek.new(all_data, "current").gw_num
    @transfers = Gameweek.new(all_data, "current").transfers
  end
end
