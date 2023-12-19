class AddGameweekToPicks < ActiveRecord::Migration[7.1]
  def change
    add_column :picks, :gameweek, :integer
  end
end
