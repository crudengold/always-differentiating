class AddStatusToPenalties < ActiveRecord::Migration[7.1]
  def change
    add_column :penalties, :status, :string, default: 'pending'
  end
end
