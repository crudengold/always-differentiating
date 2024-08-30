require 'open-uri'

namespace :players do
  desc "Get all FPL shirts"
  task get_shirts: :environment do
    shirt_codes = Player.pluck(:shirt).uniq

    shirt_codes.each do |team|
      url = "https://fantasy.premierleague.com/dist/img/shirts/standard/shirt_#{team}_1-220.webp"
      File.open("app/assets/images/#{team}_gk.png", "wb") do |file|
        file.write(URI.open(url).read)
      end
      url = "https://fantasy.premierleague.com/dist/img/shirts/standard/shirt_#{team}-220.webp"
      File.open("app/assets/images/#{team}.png", "wb") do |file|
        file.write(URI.open(url).read)
      end
    end
  end
end
