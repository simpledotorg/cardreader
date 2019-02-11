module ApplicationHelper
  NOT_AVAILABLE = "N/A"

  def display_percentage(value)
    value.finite? ? number_to_percentage(value, precision: 2) : raw(NOT_AVAILABLE)
  end

  def display_readable_time(time)
    display_not_available_if_false(time&.strftime("%b #{time.day.ordinalize} %Y, %-l:%M %p"))
  end

  def display_not_available_if_false(obj)
    obj || raw(NOT_AVAILABLE)
  end
end
