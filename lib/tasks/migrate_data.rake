namespace :migrate_data do
  desc 'Migrate old records to have author'
  task add_author: :environment do
    existing_author = User.find_by(email: 'default_author@simple..org')
    author =
      if existing_author.present?
        existing_author
      else
        User.create(
          email: 'default_author@simple.org',
          password: ENV.fetch('DEFAULT_AUTHOR_PASSWORD'),
          role: 'operator'
        )
      end

    [Facility, Patient, Visit].each do |model|
      model.where(author: nil).update_all(author_id: author.id)
    end
  end
end