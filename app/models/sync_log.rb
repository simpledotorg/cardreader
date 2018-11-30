class SyncLog < ApplicationRecord
  validates :synced_at, presence: true
  validates :simple_model, presence: true
  validates :simple_id, presence: true
end