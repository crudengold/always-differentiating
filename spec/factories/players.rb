# spec/factories/players.rb
FactoryBot.define do
  factory :player do
    factory :over_15_player do
      fpl_id { 1 }
      past_ownership_stats { { "35" => 16.0 } }
    end
    factory :over_10_player do
      fpl_id { 2 }
      past_ownership_stats { { "35" => 11.0 } }
    end
    factory :under_10_player do
      fpl_id { 3 }
      past_ownership_stats { { "35" => 9.0 } }
    end
  end
end
