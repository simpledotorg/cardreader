class FacilitySyncReport < Struct.new(:facility)
  include SyncReportable

  def highest_treatment_number
    patients.max_by { |p| p.treatment_number_without_prefix.to_i }&.treatment_number
  end

  private

  def patients
    @patients ||= facility.patients
  end
end
