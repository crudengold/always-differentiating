class Player < ApplicationRecord
  has_many :picks
  has_many :fplteams, through: :picks
end
