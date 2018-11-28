require 'net/http'

class SyncService
  attr_reader :request_key, :host, :user_id, :access_token

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(host, user_id, access_token)
    @host = host
    @user_id = user_id
    @access_token = access_token
  end

  def sync(request_key, records, request_payload, report_errors_on_class: nil)
    begin
      request = to_request(request_key, records, request_payload)
      response = api_post("api/v1/#{request_key.to_s}/sync", Hash[request_key.to_sym, request])
      error_ids = JSON(response.body)['errors'].map { |error| error['id'] }
      success_ids = request.map { |record| record[:id] }.reject { |id| error_ids.include?(id) }
      if report_errors_on_class.present?
        uuid_field = "#{request_key.to_s.singularize}_uuid"
        success_ids.each do |id|
          report_errors_on_class.find_by(uuid_field => id).update_columns(synced_at: Time.now, last_sync_errors: nil)
        end
        JSON(response.body)['errors'].map do |error|
          report_errors_on_class.find_by(uuid_field => error['id']).update_column(:last_sync_errors, error)
        end
      end
    rescue => error
      puts "Could not sync #{request_key}. Error: #{error.message}"
    end
  end

  def to_request(request_key, records, request_payload)
    requests = records.flat_map do |record|
      begin
        request_payload.new(record, user_id).to_payload
      rescue => error
        write_errors_to_file(request_key, [record.attributes.merge(error: [error.message])])
        nil
      end
    end
    requests.compact
  end

  private

  def error_file(request_key)
    "#{request_key}-errors-#{Date.today.iso8601}.csv"
  end

  def now
    Time.now
  end

  def api_post(path, request_body)
    uri = URI.parse(host + path)
    header = { 'Content-Type' => 'application/json',
               'ACCEPT' => 'application/json',
               'X-USER-ID' => user_id,
               'Authorization' => "Bearer #{access_token}" }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = ENV['USE_SSL'].present? ? ENV['USE_SSL'] == 'true' : true
    http.read_timeout = 500
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = request_body.to_json
    http.request(request)
  end
end