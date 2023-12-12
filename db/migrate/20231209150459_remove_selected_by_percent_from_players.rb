class RemoveSelectedByPercentFromPlayers < ActiveRecord::Migration[7.1]
  def change
    remove_column :players, :selected_by_percent
  end
end
