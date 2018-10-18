module PatientsHelper
  def display_yes_no_field(value)
    case value
    when true
      "Yes"
    when false
      "No"
    else
      "Don't Know"
    end
  end
end
