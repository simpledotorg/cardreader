class FacilitySyncReport < Struct.new(:facility)
  include SyncReportable

  def last_synced_at
    @time ||= patients
                .joins("INNER JOIN sync_logs ON sync_logs.simple_id = patients.patient_uuid")
                .where(sync_logs: { sync_errors: nil })
                .maximum('sync_logs.synced_at')

    @time&.to_formatted_s(:long)
  end

  def highest_treatment_number
    patients.max do |p1, p2|
      treatment_number2int(p1.treatment_number) <=> treatment_number2int(p2.treatment_number)
    end&.treatment_number
  end

  private

  def treatment_number2int(number)
    number.gsub('-', '').to_i
  end

  def patients
    @patients ||= facility.patients
  end
end
