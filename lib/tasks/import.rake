namespace :import do
  desc 'Import facilities from simple server'
  task facilities: :environment do
    host = ENV.fetch('SIMPLE_SERVER_HOST')

    ImportFacilitiesService.new(host).import
  end

  desc 'Import card data from spreadsheet'
  task :card_data, [:card_data_file] => :environment do |_t, args|
    ImportCardsService.new(open(args.card_data_file)).import
  end
end