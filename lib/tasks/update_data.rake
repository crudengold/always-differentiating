require_relative "../../app/helpers/json_helper.rb"
require_relative "../../app/services/api_json.rb"

namespace :data do
  include JsonHelper
  desc "Get all FPL data from the api"
  task update_data: :environment do
    all_data = ApiJson.new("https://fantasy.premierleague.com/api/bootstrap-static/").get
    save_to_file(all_data)
  end
end
