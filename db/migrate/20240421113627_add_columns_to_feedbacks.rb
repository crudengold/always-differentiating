class AddColumnsToFeedbacks < ActiveRecord::Migration[7.1]
  def change
    add_column :feedbacks, :name, :string
    add_column :feedbacks, :feedback, :text
  end
end
