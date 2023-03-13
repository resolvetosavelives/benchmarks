# frozen_string_literal: true

class UserRemoveAdmin < Avo::BaseAction
  self.name = "Remove Admin"
  self.message = "Are you sure? All selected users will lose admin privileges."
  self.confirm_button_label = "Remove Admin"
  self.visible = ->(resource:, view:) { view == :index }

  def handle(**args)
    users, current_user = args.values_at(:models, :current_user)

    if users.include?(current_user)
      fail "You cannot remove your own admin privileges. No users have been changed."
      return
    end

    users.each(&:remove_admin!)
    succeed "The user(s) are no longer admins"
    reload
  end
end
