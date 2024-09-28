require "json"
require "open-uri"

class FetchApiData
  def initialize(fpl_data)
    @fpl_data = fpl_data
  end

  def call
    Rails.cache.fetch("fpl_data") do
      p "Fetching data from API"
      fetch_data
    end
    p "Data fetched"
  end

  def retrieve_cached_data
    Rails.cache.read("fpl_data")
  end

  def clear_cache
    p "Clearing cache"
    Rails.cache.clear
  end

  private

  def fetch_data
    user_serialized = URI.open(@fpl_data).read
    JSON.parse(user_serialized)
  end
end
