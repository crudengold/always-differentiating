class AddShirtsToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :shirt, :integer
  end
end
