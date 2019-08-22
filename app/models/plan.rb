class Plan < ApplicationRecord
  belongs_to :user, optional: true
end
