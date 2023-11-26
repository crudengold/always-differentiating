class AddColumnsToFplteams < ActiveRecord::Migration[7.1]
  def change
    add_column :fplteams, :event_total, :integer
    add_column :fplteams, :player_name, :string
    add_column :fplteams, :rank, :integer
    add_column :fplteams, :last_rank, :integer
    add_column :fplteams, :rank_sort, :integer
    add_column :fplteams, :total, :integer
    add_column :fplteams, :entry, :integer
    add_column :fplteams, :entry_name, :string
  end
end
