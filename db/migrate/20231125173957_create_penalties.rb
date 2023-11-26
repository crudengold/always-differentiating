class CreatePenalties < ActiveRecord::Migration[7.1]
  def change
    create_table :penalties do |t|
      t.integer :points_deducted
      t.references :fplteam, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
