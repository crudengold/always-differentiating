require "json"
require "open-uri"
require "date"
require "time"
require_relative "../services/api_json.rb"
require_relative "../services/gameweek.rb"


class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, only: [:admin]
  before_action :set_gameweek_data, only: [:home]
  before_action :set_penalties, only: [:home]
  before_action :set_transfers, only: [:home]
  before_action :determine_screenshot_changes, only: [:home]

  def home
    @update_time = (Player.last.updated_at).in_time_zone("London")
  end

  def test
  end

  def new
  end

  def transfers
    all_data = ApiJson.new("https://fantasy.premierleague.com/api/bootstrap-static/").get
    @current_gameweek = Gameweek.new(all_data, "current").gw_num
    @transfers = Gameweek.new(all_data, "current").transfers
  end

  def admin
    @jobs = Sidekiq::ScheduledSet.new
    @penalties = Penalty.where("status = 'confirmed'").last(3).sort_by(&:gameweek).reverse
    @feedback = Feedback.last(3)
  end

  def rules
  end

  def update_scores
    UpdateTeamScoresJob.perform_now
    redirect_to root_path
  end

  private

  def set_gameweek_data
    @current_gw_data = Gameweek.new("current")
    @next_gw_data = Gameweek.new("next")

    @next_gw = @next_gw_data.gw_num
    @current_gw = @current_gw_data.gw_num

    @next_deadline = @next_gw_data.deadline
    @next_deadline_minus_one = @next_deadline - 24.hours

    @illegal_players = sorted_illegal_players(@next_gw_data.illegal_players)
    @last_week_illegal_players = sorted_illegal_players(@current_gw_data.illegal_players)
  end

  def set_penalties
    last_penalty_week = Penalty.where("status = 'confirmed'").last.gameweek
    @latest_confirmed_penalties = Penalty.where("status = 'confirmed' AND gameweek = ?", last_penalty_week)
  end

  def sorted_illegal_players(players)
    players.sort_by { |_key, value| -value }.to_h
  end

  def screenshot_changes(gameweek)
    next_week_illegal_players = Player.with_ownership_above(gameweek, 10)
    current_week_illegal_players = Player.with_ownership_above((gameweek - 1), 10)
    now_illegal = next_week_illegal_players - current_week_illegal_players
    now_legal = current_week_illegal_players - next_week_illegal_players
    {now_illegal: now_illegal, now_legal: now_legal}
  end

  def set_transfers
    @transfers = @current_gw < 2 ? {} : @current_gw_data.transfers
  end

  def determine_screenshot_changes
    if @illegal_players.empty?
      @screenshot_changes = screenshot_changes(@current_gw)
    else
      @screenshot_changes = screenshot_changes(@next_gw)
    end
  end
end
