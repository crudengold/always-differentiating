require 'open-uri'

class DownloadShirtsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    # go through every player
    team_codes = ["ars", "avl", "bha", "bur", "bou", "bre", "che", "cry", "eve", "ful", "liv", "lut", "mci", "mun", "new", "nfo", "shu", "tot", "whu", "wol"]
    team_codes.each do |team|
      url = "https://www.fplgameweek.com/shirts/#{team}2.png"
      File.write "#{team}.png", open(url).read
      # file = open(url)
      # IO.copy_stream(file, "app/assets/images/shirts/#{team}.png")
    end
    # if not, use player.shirt number to download it
  end
end
