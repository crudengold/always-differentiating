class AddPicksToFplteams < ActiveRecord::Migration[7.1]
  def change
    add_column :fplteams, :picks, :jsonb, default: {}, null: false
  end
end
