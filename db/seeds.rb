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

    5.times.each do |id|
      patient = facility.patients.create(
        treatment_number: "2018-%08i" % (id + 1),
        registered_on: Faker::Date.between(3.months.ago, Date.today),
        name: "Test User #{id + 1}",
        age: rand(18..80),
        village: "Test Village #{id + 1}",
        district: district.name,
        phone: "9123456789"
      )

      3.times.each do
        measured_on = Faker::Date.between(3.months.ago, Date.today)

        patient.visits.create(
          systolic: rand(110..190),
          diastolic: rand(70.140),
          measured_on: measured_on,
          amlodipine: "10mg",
          telmisartan: "40mg",
          next_visit_on: measured_on + 1.month
        )
      end
    end
  end
end
