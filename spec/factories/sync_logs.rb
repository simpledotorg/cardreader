FactoryBot.define do
  factory :sync_log do
    simple_id { SecureRandom.uuid }
    simple_model 'Patient'
    synced_at { Time.now }

    trait(:with_sync_errors) do
      sync_errors do
        { "error" => ["There was a sync error for the record"],
          "id" => simple_id }
      end
    end
  end
end
