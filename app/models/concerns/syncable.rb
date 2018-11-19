module Syncable
  extend ActiveSupport::Concern

  def synced?
    synced_at.present? && (synced_at >= updated_at)
  end

  def last_sync_error
    error_string = self[:last_sync_error]
    JSON.parse error_string if error_string.present?
  end

  def last_sync_error=(hash)
    self[:last_sync_error] = hash.present? ? hash.to_json : nil
  end
end