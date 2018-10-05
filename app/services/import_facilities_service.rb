require 'net/http'

class ImportFacilitiesService
  def initialize(host, processed_since: Time.new(0))
    @host = host
    @processed_since = processed_since
  end

  def import
    uri = URI("#{host}api/v1/facilities/sync?process_since=#{processed_since}&limit=1000")
    response = Net::HTTP.get_response(uri)
    response_body = JSON(response.body)
    return unless response_body['facilities'].present?
    response_body['facilities'].each do |facility|
      save_facility(facility)
    end
  end

  private

  attr_reader :host, :processed_since

  def save_facility(facility)
    district = save_district(facility['district'])
    existing_facility = Facility.find_by(name: facility['name'], district: district)
    return if existing_facility.present?
    puts "Creating facility: #{facility['name']}"
    Facility.create(
      name: facility['name'],
      district_id: district.id,
      simple_uuid: facility['id']
    )
  end

  def save_district(district_name)
    existing_district = District.find_by('lower(name) = ?', district_name.downcase)
    return existing_district if existing_district.present?
    District.create(name: district_name)
  end
end