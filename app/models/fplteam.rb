class Fplteam < ApplicationRecord
  has_many :players, through: :picks
  has_many :picks
end
