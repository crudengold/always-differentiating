class Player < ApplicationRecord
  has_many :picks, dependent: :destroy
  has_many :fplteams, through: :picks
  has_many :selected_by_stats, dependent: :destroy
  has_many :penalties, dependent: :destroy
end
