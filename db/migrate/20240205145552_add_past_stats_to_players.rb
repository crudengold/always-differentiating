class AddPastStatsToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :past_ownership_stats, :text
  end
end
