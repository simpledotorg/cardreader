require 'net/http'

class SyncService
  attr_reader :request_key, :host, :user_id, :access_token

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(host, user_id, access_token)
    @host = host
    @user_id = user_id
    @access_token = access_token
  end

  def sync(request_key, records, request_payload)
    request = to_request(records, request_payload)
    return if request.empty?
    response = api_post("api/v1/#{request_key.to_s}/sync", Hash[request_key.to_sym, request])
    errors = JSON(response.body)['errors'].map do |error|
      uuid_field = "#{request_key.to_s.singularize}_uuid"
      records.first.class.find_by(Hash[uuid_field, error['id']]).attributes.merge(error: error.except('id'))
    end
    write_errors_to_file(request_key, errors)
  end

  def to_request(records, request_payload)
    requests = records.flat_map do |record|
      begin
        request_payload.new(record, user_id).to_request
      rescue => error
        puts error
        write_errors_to_file(request_key, [record.attributes.merge(error: [error.message])])
        nil
      end
    end
    requests.reject(&:nil?)
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
    "#{request_key}-errors-#{Time.now.to_i.to_s}.csv"
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