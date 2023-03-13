# frozen_string_literal: true

class UserResource < Avo::BaseResource
  self.title = :first_name
  self.description = "User accounts of IHR Benchmarks"
  self.record_selector = true

  field :first_name, as: :text, sortable: true, required: false, readonly: true
  field :last_name, as: :text, sortable: true, required: false, readonly: true
  field :email, as: :text, sortable: true, required: true, readonly: true
  field :country_alpha3,
        as: :text,
        name: "Country",
        sortable: true,
        readonly: true
  field :institution, as: :text, sortable: true, readonly: true
  field :affiliation,
        as: :select,
        required: true,
        sortable: true,
        options: User::AFFILIATIONS.to_h { |value| [value, value] }
  field :access_reason, as: :text, sortable: true, readonly: true
  field :status, as: :text, sortable: true, readonly: true

  field :is_admin,
        as: :boolean,
        sortable: ->(query, direction) {
          query.order(role: direction)
        } do |model, resource, view|
    model.admin?
  end

  action UserMakeAdmin
  action UserRemoveAdmin

  filter UserEmailOrNameFilter
  filter UserCountryFilter
end
