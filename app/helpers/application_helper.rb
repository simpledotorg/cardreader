module ApplicationHelper
  def show_percentage(value)
    number_to_percentage(value, precision: 2)
  end
end
