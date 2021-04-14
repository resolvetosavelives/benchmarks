class ActionDocument < ApplicationRecord
  belongs_to :benchmark_indicator_action
  belongs_to :reference_library_document
end
