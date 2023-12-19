require "json"
require "open-uri"
require "date"
require "time"


class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

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
    @gameweek = 17
    @deadline_minus_one = @deadline - 24.hours
    @update_time = SelectedByStat.last.created_at
    @illegal_players = SelectedByStat.where("selected_by > ? AND gameweek = ?", 10, @gameweek).order(selected_by: :desc)
    @illegal_players.empty?
    @penalties = Penalty.where("gameweek = ?", @gameweek)
    @penalty_players = Penalty.distinct.pluck(:player_id)
  end

  def new
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

  def get_shirts()

  end
end
