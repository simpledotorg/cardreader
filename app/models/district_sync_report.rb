class DistrictSyncReport < Struct.new(:district)
  include SyncReportable

  def last_synced_at
    @time ||= facilities
                .joins("INNER JOIN sync_logs ON sync_logs.simple_id = patients.patient_uuid")
                .where(sync_logs: { sync_errors: nil })
                .maximum('sync_logs.synced_at')

    @time&.to_formatted_s(:long)
  end

  def highest_treatment_number
    'N/A'
  end

  private

  def patients
    @patients ||= facilities.flat_map(&:patients)
  end

  def facilities
    @facilities ||= district.facilities.includes(:patients)
  end
end
