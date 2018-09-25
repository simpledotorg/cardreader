# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

District.destroy_all
Facility.destroy_all
Patient.destroy_all
Visit.destroy_all

%w(
  Bathinda
  Gurdaspur
  Hoshiarpur
  Mansa
  Pathankot
).each do |district_name|
  district = District.create(
    name: district_name
  )

  3.times.each do
    facility_type = %w(DH SDH CHC PHC).sample

    facility = district.facilities.create(
      name: "#{facility_type} #{Faker::Address.city}"
    )

    3.times.each do |id|
      patient = facility.patients.create(
        treatment_number: "2018-%08i" % (id + 1),
        registered_on: Faker::Date.between(3.months.ago, Date.today),
      )

      3.times.each do
        patient.visits.create(
          systolic: Faker::Number.between(140, 190),
          diastolic: Faker::Number.between(90, 140),
          measured_on: Faker::Date.between(3.months.ago, Date.today),
        )
      end
    end
  end
end
