require "json"
require "open-uri"

class ApiJson
  def initialize(url)
    @url = url
  end

  def get
    # binding.pry
    user_serialized = URI.open(@url).read
    all_data = JSON.parse(user_serialized)
  end
end
