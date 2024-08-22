class Player < ApplicationRecord
  has_many :picks, dependent: :destroy
  has_many :fplteams, through: :picks
  has_many :selected_by_stats, dependent: :destroy
  has_many :penalties, dependent: :destroy
  serialize :past_ownership_stats, type: Hash, coder: JSON

  scope :with_ownership_above, ->(gameweek, threshold) {
    where("past_ownership_stats::jsonb ->> ? IS NOT NULL AND (past_ownership_stats::jsonb ->> ?)::float >= ?", gameweek.to_s, gameweek.to_s, threshold)
  }

  def self.create_or_update_player(player, gameweek)
    player_record = Player.find_by(fpl_id: player["id"])

    if player_record.nil?
      player_record = Player.new
      player_record.web_name = player["web_name"]
      player_record.code = player["code"]
      player_record.element_type = player["element_type"]
      player_record.event_points = player["event_points"]
      player_record.first_name = player["first_name"]
      player_record.fpl_id = player["id"]
      player_record.photo = player["photo"]
      player_record.second_name = player["second_name"]
      player_record.team = player["team"]
      player_record.total_points = player["total_points"]
      player_record.shirt = player["team_code"]
      puts "#{player_record.web_name} created"
    else
      player_record.total_points = player["total_points"]
    end

    player_record.past_ownership_stats[gameweek.to_s] = player["selected_by_percent"].to_f
    player_record.save!
    puts "stat created for #{player_record.web_name}\n"
  end

  def self.illegal_players(gameweek)
    threshold = 10
    players = {}

    with_ownership_above(gameweek, threshold).each do |player|
      players[player] = player.past_ownership_stats[gameweek.to_s]
    end

    players
  end
end
