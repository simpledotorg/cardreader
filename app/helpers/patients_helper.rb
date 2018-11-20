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

  def visit_info(attr_name, value)
    if value.present?
      content_tag(:span, value, class: "visit-info visit-#{attr_name}")
    else
      content_tag(:span, "none", class: "visit-info visit-info-null visit-#{attr_name}")
    end
  end

  def visit_info_drug(attr_name, name, dose)
    if name.present?
      content_tag(:span, "#{name}<br>#{dose}".html_safe, class: "visit-info visit-#{attr_name}")
    else
      content_tag(:span, "none", class: "visit-info visit-info-null visit-#{attr_name}")
    end
  end
end
