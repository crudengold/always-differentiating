class Fplteam < ApplicationRecord
  has_many :players, through: :picks
  has_many :picks
  has_many :penalties

  def free_hit?(team_entry, gameweek)
    url = "https://fantasy.premierleague.com/api/entry/#{team_entry}/event/#{gameweek}/picks/"
    api_data = ApiJson.new(url).get
    api_data["active_chip"] == "freehit"
  end

  def self.create_picks_for_gameweek(gameweek)
    Fplteam.all.each do |manager|
      puts "getting picks for #{manager.entry_name}"
      manager_url = "https://fantasy.premierleague.com/api/entry/#{manager.entry}/event/#{gameweek}/picks/"
      user_serialized = URI.open(manager_url).read
      all_data = JSON.parse(user_serialized)
      puts "API accessed and loaded"
      # get their picks
      all_data["picks"].each do |player|
        player_log = Player.find_by(fpl_id: player["element"])
        # create a new pick for each player
        pick = Pick.new
        pick.player = player_log
        pick.fplteam = manager
        pick.gameweek = gameweek
        pick.save
        puts "pick created for #{player_log.web_name}!"
      end
    end
  end

end
