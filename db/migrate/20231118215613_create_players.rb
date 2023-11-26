class CreatePlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :players do |t|
      t.integer :code
      t.integer :element_type
      t.integer :event_points
      t.string :first_name
      t.integer :fpl_id
      t.string :photo
      t.string :second_name
      t.float :selected_by_percent
      t.integer :team
      t.integer :total_points
      t.string :web_name

      t.timestamps
    end
  end
end
