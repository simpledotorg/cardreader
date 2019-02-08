class DistrictSyncReport < Struct.new(:district)
  include SyncReportable

  private

  def patients
    @patients ||= Patient.where(id: facilities.flat_map(&:patients).map(&:id))
  end

  def facilities
    @facilities ||= district.facilities.includes(:patients)
  end
end
