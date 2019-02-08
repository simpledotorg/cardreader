class FacilitySyncReport < Struct.new(:facility)
  def last_synced_at
    time = patients
             .joins("INNER JOIN sync_logs ON sync_logs.simple_id = patients.patient_uuid")
             .where(sync_logs: { sync_errors: nil })
             .maximum('sync_logs.synced_at')

    time&.to_formatted_s(:long)
  end

  def synced_patients
    patients.select(&:synced?).size
  end

  def unsynced_patients
    patients.select(&:unsynced?).size
  end

  def errored_patients
    latest_sync_log_subquery = "SELECT max(synced_at) FROM sync_logs WHERE simple_id = patients.patient_uuid"

    patients
      .joins("INNER JOIN sync_logs ON sync_logs.simple_id = patients.patient_uuid",
             "AND sync_logs.synced_at = (#{latest_sync_log_subquery})")
      .where(sync_logs: { simple_model: 'Patient' })
      .where.not(sync_logs: { sync_errors: nil })
      .count
  end

  def highest_treatment_number
    patients
      .map(&:treatment_number)
      .max { |t1, t2| treatment_number2int(t1) <=> treatment_number2int(t2) }
  end

  private

  def treatment_number2int(number)
    number.gsub('-', '').to_i
  end

  def patients
    @patients ||= facility.patients
  end
end
