class RemovePlayersFromFplteams < ActiveRecord::Migration[7.1]
  def change
    remove_reference :fplteams, :players, null: false, foreign_key: true
  end
end
