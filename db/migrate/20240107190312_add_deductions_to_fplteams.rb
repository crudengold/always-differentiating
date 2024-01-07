class AddDeductionsToFplteams < ActiveRecord::Migration[7.1]
  def change
    add_column :fplteams, :deductions, :integer, default: 0
    add_column :fplteams, :total_after_deductions, :integer, default: 0
  end
end
