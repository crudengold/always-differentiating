require_relative "../helpers/json_helper.rb"

class UpdateDataJob < ApplicationJob
  queue_as :default
  include JsonHelper

  def perform(data)
    save_to_file(data)
  end
end
