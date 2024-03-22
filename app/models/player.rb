class Player < ApplicationRecord
  has_many :picks, dependent: :destroy
  has_many :fplteams, through: :picks
  has_many :selected_by_stats, dependent: :destroy
  has_many :penalties, dependent: :destroy
  serialize :past_ownership_stats, type: Hash, coder: JSON
  # I’ve not used serialize, but I think this is equivalent to having a JSON column
  # in the database. The benefit of this is you that the database itself can query within
  # a JSON column, so you can do things like:
  # Player.where("past_ownership_stats->>'gameweek'='12'") or similar
end
