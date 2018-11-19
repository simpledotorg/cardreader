require 'net/http'

class SyncService
  attr_reader :request_key, :host, :user_id, :access_token

  API_VERSION = 'v2'.freeze

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(host, user_id, access_token)
    @host = host
    @user_id = user_id
    @access_token = access_token
  end

  def sync(request_key, records, request_payload, report_errors_on_class: nil)
    begin
      request = to_request(request_key, records, request_payload)
      response = api_post(sync_path(request_key), Hash[request_key.to_sym, request])
      errors = JSON(response.body)['errors'].map do |error|
        if report_errors_on_class.present?
          uuid_field = "#{request_key.to_s.singularize}_uuid"
          report_errors_on_class.find_by(Hash[uuid_field, error['id']]).attributes.merge(error: error.except('id'))
        else
          error
        end
      end
      write_errors_to_file(request_key, errors)
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

  def write_errors_to_file(request_key, errors)
    return unless errors.present?
    CSV.open(error_file(request_key), "wb+") do |csv|
      csv << errors.first.keys # adds the attributes name on the first line
      errors.each do |error|
        csv << error.values
      end
    end
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

  def sync_path(request_key)
    "api/#{API_VERSION}/#{request_key.to_s}/sync"
  end
end