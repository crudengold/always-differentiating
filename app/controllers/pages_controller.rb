require "json"
require "open-uri"
require "date"
require "time"


class PagesController < ApplicationController
  def home
    @illegal_players = Player.where("selected_by_percent > ?", 10).order(selected_by_percent: :desc)
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
end
