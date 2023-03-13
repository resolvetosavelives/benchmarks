class UserEmailOrNameFilter < Avo::Filters::TextFilter
  self.name = "Email, first name, or last name"
  self.button_label = "Filter"

  def apply(request, query, value)
    str_contains = "%#{value.to_s.downcase}%"
    query.where(
      "LOWER(email) LIKE ? OR LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?",
      str_contains,
      str_contains,
      str_contains
    )
  end
end
