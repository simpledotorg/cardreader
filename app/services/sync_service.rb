require 'net/http'

class SyncService
  attr_reader :host, :user_id, :access_token

  def initialize(host, user_id, access_token)
    @host = host
    @user_id = user_id
    @access_token = access_token
  end

  def sync_bulk(request_key, records, payload_class, sync_class)
    begin
      payload = to_request_payload(request_key, payload_class, records)
      response = request(request_key, payload)
      errors = JSON(response.body)['errors']
      after_bulk_response(request_key, payload, errors, sync_class)
    rescue => error
      puts "Could not sync #{request_key}. Error: #{error.message}"
    end
  end

  def after_bulk_response(request_key, payload, errors, sync_class)
    failed_record_ids = []
    errors.each do |error|
      record = from_uuid(request_key, sync_class, error['id'])
      record.last_sync_error = error.except('id')
      failed_record_ids << record.id
    end
    payload.each do |hash|
      record = from_uuid(request_key, sync_class, hash['id'])
      unless failed_record_ids.include?(record.id)
        record.update_attributes(synced_at: now, last_sync_error: nil)
      end
    end
  end

  def sync_one_by_one(request_key, records, payload_class)
    records.each do |record|
      begin
        payload = to_request_payload(request_key, payload_class, [record])
        response = request(request_key, payload)
        error = payload, JSON(response.body)['errors'].first
        after_single_response(error, record)
      rescue => error
        puts "Could not sync #{request_key}. Error: #{error.message}"
      end
    end
  end

  def after_single_response(error, record)
    if error.present?
      record.last_sync_error = error.except('id')
    else
      record.update_attributes(synced_at: Time.now, last_sync_error: nil)
    end
  end

  def from_uuid(request_key, sync_class, uuid)
    uuid_field = "#{request_key.to_s.singularize}_uuid"
    sync_class.find_by(Hash[uuid_field, uuid])
  end

  def to_request_payload(request_key, payload_class, records)
    errors = []
    requests = records.flat_map do |record|
      begin
        payload_class.new(record, user_id).to_payload
      rescue => error
        errors << record.attributes.merge(error: [error.message])
        nil
      end
    end
    write_errors_to_file(request_key, errors)
    requests.compact
  end

  private

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

  def request(request_key, payload)
    api_post("api/v1/#{request_key.to_s}/sync", Hash[request_key.to_sym, payload])
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

  def error_file(request_key)
    "#{request_key}-errors-#{Date.today.iso8601}.csv"
  end
end