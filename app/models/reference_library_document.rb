# frozen_string_literal: true

require "csv"

class ReferenceLibraryDocument < ApplicationRecord
  include ReferenceLibraryDocumentSeed

  has_and_belongs_to_many :benchmark_indicator_actions,
                          join_table: :actions_and_documents

  validates :download_url, uniqueness: true

  REFERENCE_TYPES = [
    "Briefing Note",
    "Case Study",
    "Example",
    "Guideline",
    "Manual",
    "Template",
    "Tool",
    "Training Package"
  ].freeze

  def self.reference_type_scope_name(reference_type_name)
    reference_type_name.parameterize(separator: "_").pluralize.to_sym
  end

  REFERENCE_TYPES.each do |rt|
    scope self.reference_type_scope_name(rt), -> { where(reference_type: rt) }
  end

  def self.reference_type_ordinal(reference_type_name)
    index = REFERENCE_TYPES.index(reference_type_name)
    return nil if index.nil?

    index + 1
  end

  def reference_type_ordinal
    ReferenceLibraryDocument.reference_type_ordinal(reference_type)
  end
end
