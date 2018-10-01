namespace :import do
  desc 'Import facilities from simple server'
  task facilities: :environment do
    host = ENV.fetch('SIMPLE_SERVER_HOST')

    ImportFacilitiesService.new(host).import
  end
end