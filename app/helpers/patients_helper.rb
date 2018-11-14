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

  def visit_info(value)
    if value.present?
      content_tag(:span, class: "visit-info") { value }
    else
      content_tag(:span, class: "visit-info visit-info-null") { value }
    end
  end
end
