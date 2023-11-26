class CreatePicks < ActiveRecord::Migration[7.1]
  def change
    create_table :picks do |t|
      t.references :player, null: false, foreign_key: true
      t.references :fplteam, null: false, foreign_key: true

      t.timestamps
    end
  end
end
