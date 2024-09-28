# spec/services/fetch_api_data_spec.rb
require 'rails_helper'

RSpec.describe FetchApiData, type: :service do
  let(:url) { "https://fantasy.premierleague.com/api/bootstrap-static/" }
  let(:service) { FetchApiData.new(url) }
  let(:response_body) { { "key" => "value" }.to_json }

  before do
    allow(URI).to receive(:open).with(url).and_return(double(read: response_body))
  end

  describe "#call" do
    context "when data is not cached" do
      it "fetches data from the API and caches it" do
        expect(Rails.cache).to receive(:fetch).with("fpl_data").and_call_original
        expect(service.call).to eq(JSON.parse(response_body))
      end
    end

    context "when data is cached" do
      before do
        Rails.cache.write("fpl_data", JSON.parse(response_body))
      end

      it "returns cached data" do
        expect(Rails.cache).to receive(:fetch).with("fpl_data").and_call_original
        expect(service.call).to eq(JSON.parse(response_body))
      end
    end
  end
end
