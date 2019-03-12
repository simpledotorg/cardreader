module SimpleServerImportable
  extend ActiveSupport::Concern

  SIMPLE_SERVER_HOST = ENV.fetch('SIMPLE_SERVER_HOST')

  included do
    def import_facilities_for_district(host, district)
      import_facility_service = ImportFacilitiesService.new(host)
      import_facility_service.import_for_district(district)
    end
  end
end
