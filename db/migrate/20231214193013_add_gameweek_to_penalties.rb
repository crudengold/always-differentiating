class AddGameweekToPenalties < ActiveRecord::Migration[7.1]
  def change
    add_column :penalties, :gameweek, :integer
  end
end
