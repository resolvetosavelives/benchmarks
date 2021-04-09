# frozen_string_literal: true

require "csv"

class ReferenceLibraryDocument < ApplicationRecord
  include ReferenceLibraryDocumentSeed

  has_and_belongs_to_many :benchmark_indicator_actions,
                          join_table: :actions_and_documents

  validates :download_url, uniqueness: true
end
