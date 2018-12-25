namespace :migrate_data do
  desc 'Migrate old records to have author'
  task add_author: :environment do
    dummy_author = User.find_or_create_by(email: 'default_author@simple.org')

    [Facility, Patient, Visit].each do |model|
      model.where(author: nil).update_all(author_id: dummy_author.id)
    end
  end
end