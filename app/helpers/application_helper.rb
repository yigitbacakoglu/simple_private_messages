module ApplicationHelper

  def format_date(date = nil)
    return "" if date.nil?
    date.strftime("%B %d at %I:%M%p")
  end

end
