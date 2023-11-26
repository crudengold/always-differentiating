class AddDiscordNameToFplteams < ActiveRecord::Migration[7.1]
  def change
    add_column :fplteams, :discord_name, :string
  end
end
