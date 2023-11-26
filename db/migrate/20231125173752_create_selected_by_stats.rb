class CreateSelectedByStats < ActiveRecord::Migration[7.1]
  def change
    create_table :selected_by_stats do |t|
      t.integer :gameweek
      t.float :selected_by
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
