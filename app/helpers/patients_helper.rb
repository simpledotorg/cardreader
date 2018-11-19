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
      content_tag(:span, value, class: "visit-info")
    else
      content_tag(:span, "none", class: "visit-info visit-info-null")
    end
  end

  def visit_info_drug(name, dose)
    if name.present?
      content_tag(:span, "#{name}<br>#{dose}".html_safe, class: "visit-info")
    else
      content_tag(:span, "none", class: "visit-info visit-info-null")
    end
  end
end
