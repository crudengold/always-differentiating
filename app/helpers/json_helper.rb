require "json"

module JsonHelper
  def save_to_file(data)
    File.open("lib/assets/data/events.json", "w") do |f|
      f.write(JSON.pretty_generate(data))
    end
  end
end
