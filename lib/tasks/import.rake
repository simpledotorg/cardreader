namespace :import do
  desc 'Import facilities from simple server'
  task facilities: :environment do
    host = ENV.fetch('SIMPLE_SERVER_HOST')

    ImportFacilitiesService.new(host).import
  end

  desc 'Import facilites for a district from simple server'
  task :district_facilities, [:district] => :environment do |_t, args|
    host = ENV.fetch('SIMPLE_SERVER_HOST')

    ImportFacilitiesService.new(host).import_for_district(args[:district])
  end

  desc 'Import card data from spreadsheet'
  task :card_data, [:card_data_file] => :environment do |_t, args|
    ImportCardsService.new(open(args.card_data_file)).import
  end

  desc 'Import sync times from CSV'
  task :sync_times, [:class_to_update, :uuid_field, :csv_file] => :environment do |_t, args|
    ImportSyncTimesService.new(args[:class_to_update].constantize,
                               args[:uuid_field],
                               open(args[:csv_file])).import
  end

  desc 'Import sync logs from simple server audit logs'
  task :sync_logs, [:audit_logs_file] => :environment do |_t, args|
    ImportSyncLogsService.new(open(args[:audit_logs_file])).import
  end
end