class ImportSyncLogsService
  attr_reader :audit_logs_file

  def initialize(audit_logs_file)
    @audit_logs_file = audit_logs_file
  end

  def import
    CSV.foreach(audit_logs_file, headers: true, header_converters: :symbol) do |row|
        SyncLog.find_or_create_by(
          simple_model: row[:auditable_type],
          simple_id: row[:auditable_id],
          synced_at: row[:created_at],
          sync_errors: nil
        )
    end
  end
end