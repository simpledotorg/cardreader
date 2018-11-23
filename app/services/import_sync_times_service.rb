class ImportSyncTimesService
  attr_reader :class_to_update, :uuid_field, :file_uri

  def initialize(class_to_update, uuid_field, file_uri)
    @class_to_update = class_to_update
    @uuid_field = uuid_field
    @file_uri = file_uri
  end

  def import
    CSV.foreach(file_uri) do |row|
      begin
        id = row.first
        synced_at = row.last.to_time

        record = class_to_update.where("#{uuid_field} = '#{id}'").first
        record.update_columns(synced_at: synced_at, last_sync_errors: nil)
      rescue => e
        puts "Error while updating #{class_to_update}.#{uuid_field} #{id}: #{e.message}"
      end
    end
  end
end