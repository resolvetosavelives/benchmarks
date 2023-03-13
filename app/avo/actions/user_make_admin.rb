# frozen_string_literal: true

class UserMakeAdmin < Avo::BaseAction
  self.name = "Make Admin"
  self.message =
    "Are you sure? All selected users will gain full admin privileges."
  self.confirm_button_label = "Make Admin"
  self.visible = ->(resource:, view:) { view == :index }

  def handle(**args)
    models = args[:models]
    models.each(&:admin!)
    succeed "The user(s) are now admins"
    reload
  end
end
