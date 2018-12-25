namespace :migrate_data do
  desc 'Migrate old records to have author'
  task :add_author do
    dummy_author = User.new(email: 'cardreader_migration_bot@simple.org')

    [Facility, Patient, Visit].each do |model|
      model.where(author: nil).update_all(author: dummy_author)
    end
  end
end