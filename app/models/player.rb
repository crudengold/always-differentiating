class Player < ApplicationRecord
  has_many :picks
  has_many :fplteams, through: :picks
  has_many :selected_by_stats
end
